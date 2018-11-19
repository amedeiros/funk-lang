module Funk
  class Parser
    property program   : Program
    property lexer     : Lexer
    property tree      : Array(Ast)
    property tokens    : Array(Token)
    property lookahead : Int32
    property index     : Int32
    property errors    : Array(String)
    property prefix_parsers : Hash(TokenType, Proc(Ast))
    property infix_parsers  : Hash(TokenType, Proc(Ast, Ast))

    enum Precedences
     LOWEST
     EQUALS
     LESS_GREATER
     SUM
     PRODUCT
     PREFIX
     CALL
    end

    PRECEDENCES = {
      TokenType::Equal        => Precedences::EQUALS,
      TokenType::NotEqual     => Precedences::EQUALS,
      TokenType::LessThan     => Precedences::LESS_GREATER,
      TokenType::LessEqual    => Precedences::LESS_GREATER,
      TokenType::GreaterThan  => Precedences::LESS_GREATER,
      TokenType::GreaterEqual => Precedences::LESS_GREATER,
      TokenType::Plus         => Precedences::SUM,
      TokenType::Minus        => Precedences::SUM,
      TokenType::Divide       => Precedences::PRODUCT,
      TokenType::Multiply     => Precedences::PRODUCT,
      TokenType::LeftParen    => Precedences::CALL,
    } of TokenType => Precedences

    def initialize(@lexer, @lookahead = 3)
      @tree    = [] of Ast
      @index   = 0
      @tokens  = [] of Token
      @errors  = [] of String
      @program = Program.new(Token.root, [] of Ast)
      @prefix_parsers = {} of TokenType => Proc(Ast)
      @infix_parsers  = {} of TokenType => Proc(Ast, Ast)
      prime
    end

    def parse! : Parser
      while (!is_end?)
        statement = parse_statement
        @program.tree << statement if statement
        consume
      end

      self
    end

    private def parse_statement : Ast
      case current.type
      when TokenType::Def
        parse_def_statement
      when TokenType::Return
        parse_return
      else
        parse_expression_statement
      end
    end

    private def parse_def_statement : Ast
      def_token = current
      expected_exception!("IDENTIFIER") if !expect_peek!(TokenType::Identifier)
      name = Identifier.new(current, current.raw)
      expected_exception!("=") if !expect_peek!(TokenType::Assignment)
      consume
      value = parse_expression(Precedences::LOWEST)

      DefStatement.new(def_token, name, value)
    end

    private def parse_return : Ast
      statement_token = current
      consume
      expression = parse_expression(Precedences::LOWEST)
      ReturnStatement.new(statement_token, expression)
    end

    private def peek_token?(token_type : TokenType)
      peek.type == token_type
    end

    # will consume if true
    private def expect_peek!(token_type : TokenType)
      if peek_token?(token_type)
        consume
        return true
      end

      peek_error(token_type)
      false
    end

    private def current : Token
      tokens[index]
    end

    private def current_token_is?(token_type : TokenType) : Bool
      current.type == token_type
    end

    private def is_end? : Bool
      current.type == TokenType::EOF
    end

    private def peek(ahead : Int32 = 1) : Token
      tokens[(index + ahead) % lookahead]
    end

    private def precedence_peek(ahead : Int32 = 1) : Precedences
      return PRECEDENCES[peek.type] if PRECEDENCES.has_key?(peek.type)
      Precedences::LOWEST
    end

    private def current_precedence : Precedences
      return PRECEDENCES[current.type] if PRECEDENCES.has_key?(current.type)
      Precedences::LOWEST
    end

    # Consume will take another token from our lexer.
    # This is a circular reference to our tokens for lookahead.
    private def consume : Void
      tokens[index] = lexer.next
      self.index    = (index + 1) % lookahead
    end

    private def prime : Void
      lookahead.times do
        tokens << lexer.next
        self.index = (index + 1) % lookahead
      end

      load_parser_blocks
    end

    private def parse_expression_statement : Ast
      ExpressionStatement.new(current, parse_expression(Precedences::LOWEST))
    end

    private def parse_expression(precedence : Precedences) : Ast
      raise Errors::SyntaxError.new("No prefix parse block found for #{current.type} at #{current.position}") if !prefix_parsers.has_key?(current.type)
      prefix         = prefix_parsers[current.type]
      leftExpression = prefix.call

      while (!peek_token?(TokenType::EOF) && precedence < precedence_peek)
        infix = infix_parsers[peek.type]
        return leftExpression unless infix
        consume

        leftExpression = infix.call leftExpression
      end

      leftExpression
    end

    private def parse_infix_expression(left : Ast) : Ast
      infix_token = current
      precedence = current_precedence
      consume
      right = parse_expression(precedence)

      # Concat check
      if infix_token.type == TokenType::Plus
        if left.token.type == TokenType::String && right.token.type != TokenType::String
          raise Errors::SyntaxError.new("Can only concat two strings #{right.token}")
        elsif right.token.type == TokenType::String && left.token.type != TokenType::String
          raise Errors::SyntaxError.new("Can only concat two strings #{left.token}")
        end
      end

      InfixExpression.new(infix_token, left, infix_token.type, right)
    end

    private def peek_error(token_type : TokenType)
      errors << "Expected next token to be #{token_type} got #{peek.type} instead at #{current.position}"
    end

    private def parse_block_statement : Block
      block_token = current
      statements  = [] of Ast
      consume
      
      while (!current_token_is?(TokenType::RightCurly) && !current_token_is?(TokenType::EOF))
        statements.push parse_statement
        consume
      end

      expected_exception!("}") if !current_token_is?(TokenType::RightCurly)
      consume

      Block.new(block_token, statements)
    end

    private def parse_lambda_parameters : Array(Ast)
      params = [] of Ast

      if !peek_token?(TokenType::RightParen)
        consume # (
        params << Identifier.new(current, current.raw)

        while peek_token?(TokenType::Comma)
          consume
          consume
          params << Identifier.new(current, current.raw)
        end

        expected_exception!(")") if !expect_peek!(TokenType::RightParen)
      else
        consume # closing )
      end

      params
    end

    private def parse_call_arguments : Array(Ast)
      args = [] of Ast
      return args if peek_token?(TokenType::RightParen)
      consume
      args << parse_expression(Precedences::LOWEST)

      while peek_token?(TokenType::Comma)
        consume
        consume
        args << parse_expression(Precedences::LOWEST)
      end

      expected_exception!(")") if !expect_peek!(TokenType::RightParen)

      args
    end

    private def expected_exception!(expected : String)
      raise Errors::SyntaxError.new("Expected #{expected} #{current.position} not #{peek}")
    end

    private def unexpected_exception!(unexpected : String)
      raise Errors::SyntaxError.new("Unexpected #{unexpected} #{current.position}")
    end

    private def raise_unexpected_any!(ast : Ast, token_types : Array(TokenType)) : Ast
      raise unexpected_exception!(peek.raw) if token_types.includes?(peek.type)
      ast
    end

    private def load_prefix_blocks
      # Identifier
      register_prefix(TokenType::Identifier) { Identifier.new(current, current.raw) }

      # Numeric
      register_prefix(TokenType::Numeric) do 
        raise_unexpected_any! Numeric.new(current, current.raw.to_f),
                              [TokenType::Numeric, TokenType::Identifier,
                              TokenType::String, TokenType::Boolean]
      end

      # String
      register_prefix(TokenType::String) do
        raise_unexpected_any! StringNode.new(current, current.raw.to_s), 
                              [TokenType::Numeric, TokenType::Identifier,
                              TokenType::String, TokenType::Boolean]
      end

      # Boolean
      register_prefix(TokenType::Boolean) do 
        raise_unexpected_any! Boolean.new(current, current.raw.upcase == "#T"),
                              [TokenType::Numeric, TokenType::Identifier,
                              TokenType::String, TokenType::Boolean]
      end

      # Bang and Minus
      [TokenType::Bang, TokenType::Minus].each do |token_type|
        register_prefix token_type do
          prefix_token = current
          prefix_raw   = prefix_token.raw
          consume
          raise unexpected_exception!("EOF") if current_token_is?(TokenType::EOF)
          raise unexpected_exception!("!") if token_type == TokenType::Bang && current_token_is?(TokenType::Bang)
          raise unexpected_exception!("-") if token_type == TokenType::Minus && current_token_is?(TokenType::Minus)

          if token_type == TokenType::Minus &&
              !current_token_is?(TokenType::Numeric) &&
              !current_token_is?(TokenType::Identifier)
            raise unexpected_exception!(current.raw)
          end
          right = parse_expression(Precedences::PREFIX)

          PrefixExpression.new(prefix_token, prefix_raw, right)
        end
      end

      # Left Paren
      register_prefix TokenType::LeftParen do
        consume
        expression = parse_expression(Precedences::LOWEST)
        
        expected_exception!(")") if !expect_peek!(TokenType::RightParen)

        expression
      end

      # If expression
      register_prefix TokenType::If do
        expression_token = current

        # Else may or may not have ()
        if expression_token.type == TokenType::Else
          if peek_token?(TokenType::LeftParen)
            consume
            expected_exception!(")") unless expect_peek!(TokenType::RightParen)
          end
        elsif !expect_peek!(TokenType::LeftParen)
          expected_exception!("(")
        end

        # Else does not have a condition
        if expression_token.type != TokenType::Else
          consume
          cond = parse_expression(Precedences::LOWEST)
        end

        # Already handled Elses possible closing ) above
        if expression_token.type != TokenType::Else && !expect_peek!(TokenType::RightParen)
          expected_exception!(")")
        end

        # Everything has a {
        expected_exception!("{") unless expect_peek!(TokenType::LeftCurly)

        consequence = parse_block_statement

        if current_token_is?(TokenType::ElsIf) || current_token_is?(TokenType::Else)
          alternative = prefix_parsers[TokenType::If].call # call this block again
        else
          alternative = Null.new(current)
        end

        IfExpression.new(expression_token, cond || Null.new(expression_token), consequence, alternative)
      end

      register_prefix TokenType::Lambda do
        current_lambda_token = current

        expected_exception!("(") if !expect_peek!(TokenType::LeftParen)
        parameters = parse_lambda_parameters
        expected_exception!("{") if !expect_peek!(TokenType::LeftCurly)

        body = parse_block_statement
        Lambda.new(current_lambda_token, parameters, body)
      end
    end
    

    private def load_infix_blocks
      [TokenType::Plus, TokenType::Minus, TokenType::Multiply, TokenType::Divide, 
      TokenType::Equal, TokenType::NotEqual, TokenType::LessThan,TokenType::GreaterThan,
      TokenType::LessEqual, TokenType::GreaterEqual].each do |infix|
        register_infix(infix) { |x| parse_infix_expression(x) }
      end

      # Function call
      register_infix TokenType::LeftParen do |func_expression|
        call_token = current
        arguments  = parse_call_arguments

        puts "Before CallExpression: #{func_expression}"
        CallExpression.new(call_token, func_expression.as(Funk::Identifier), arguments)
      end
    end

    private def load_parser_blocks
      load_prefix_blocks
      load_infix_blocks
    end

    private def register_prefix(token : TokenType, &block : -> Ast)
      prefix_parsers[token] = block
    end

    private def register_infix(token : TokenType, &block : Ast -> Ast)
      infix_parsers[token] = block
    end
  end
end
