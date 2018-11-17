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
    property infix_parsers : Hash(TokenType, Proc(Ast, Ast))

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
      @tree   = [] of Ast
      @tokens = [] of Token
      @errors = [] of String
      @program = Program.new([] of Ast)
      @prefix_parsers = {} of TokenType => Proc(Ast)
      @infix_parsers  = {} of TokenType => Proc(Ast, Ast)
      @index  = 0
      prime
    end

    def parse! : Void
      while (!is_end?)
        statement = parse_statement
        @program.tree << statement if statement
        consume
      end
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
      return Null.new if !expect_peek!(TokenType::Identifier)
      name = Identifier.new(current, current.raw)
      return Null.new if !expect_peek!(TokenType::Assignment)
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
      if prefix_parsers.has_key?(current.type)
        prefix = prefix_parsers[current.type]
      else
        no_prefix_parser_block(current.type)
        return Null.new
      end

      leftExpression = prefix.call

      while (!peek_token?(TokenType::NewLine) && precedence < precedence_peek)
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
      InfixExpression.new(infix_token, left, infix_token.type, right)
    end

    private def no_prefix_parser_block(token_type : TokenType)
      errors << "No prefix parse block found for #{token_type} at #{current.position}"
    end

    private def peek_error(token_type : TokenType)
      errors << "Expected next token to be #{token_type} got #{peek.type} instead at #{current.position}"
    end

    private def parse_block_statement : Block
      block_token = current
      statements  = [] of Ast
      consume

      while (!peek_token?(TokenType::RightParen) && !peek_token?(TokenType::EOF))
        statements.push parse_statement
        consume
      end

      if !current_token_is?(TokenType::RightCurly)
        raise Errors::ParseError.new("Expected } #{current.position} not #{peek}")
      end

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

        if !expect_peek!(TokenType::RightParen)
          raise Errors::ParseError.new("Expected ) #{current.position} not #{peek}")
        end

      else
        consume # closing )
      end

      params
    end

    private def load_prefix_blocks
      # Prefix's
      register_prefix(TokenType::Identifier) { Identifier.new(current, current.raw) }
      register_prefix(TokenType::Numeric)    { Numeric.new(current, current.raw.to_f) }

      # Bang and Minus
      [TokenType::Bang, TokenType::Minus].each do |token_type|
        register_prefix token_type do
          prefix_token = current
          prefix_raw    = prefix_token.raw
          consume
          right = parse_expression(Precedences::PREFIX)

          PrefixExpression.new(prefix_token, prefix_raw, right)
        end
      end

      # Boolean
      register_prefix(TokenType::Boolean) { Boolean.new(current, current.raw.upcase == "#T") }

      # Left Paren
      register_prefix TokenType::LeftParen do
        consume
        expression = parse_expression(Precedences::LOWEST)
        
        if !expect_peek!(TokenType::RightParen)
          expresson = Null.new
        end

        expression
      end

      # If expression
      register_prefix TokenType::If do
        # expression = IfExpression.new(current)
        expression_token = current

        if !expect_peek!(TokenType::LeftParen)
          Null.new 
        else
          consume
          cond = parse_expression(Precedences::LOWEST)

          if !expect_peek!(TokenType::RightParen)
            errors << "Missing expected ) at #{current.position}"
          end

          if errors.empty?
            if !expect_peek!(TokenType::LeftCurly)
              errors << "Missing expected { at #{current.position}"
              Null.new
            else
              consequence = parse_block_statement

              if peek_token?(TokenType::ElsIf) || peek_token?(TokenType::Else)
                alternative = prefix_parsers[TokenType::If].call # call this block again
              else
                alternative = nil
              end

              IfExpression.new(expression_token, cond, consequence, alternative)
            end
          else
            Null.new
          end
        end
      end

      register_prefix TokenType::Lambda do
        current_lambda_token = current

        if !expect_peek!(TokenType::LeftParen)
          Null.new
        else
          parameters = parse_lambda_parameters
          if !expect_peek!(TokenType::LeftCurly)
            Null.new
          else
            body = parse_block_statement
            Lambda.new(current_lambda_token, parameters, body)
          end
        end
      end
    end
    

    private def load_infix_blocks
      [TokenType::Plus, TokenType::Minus, TokenType::Multiply, TokenType::Divide, 
      TokenType::Equal, TokenType::NotEqual, TokenType::LessThan,TokenType::GreaterThan,
      TokenType::LessEqual, TokenType::GreaterEqual].each do |infix|
        register_infix(infix) { |x| parse_infix_expression(x) }
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
