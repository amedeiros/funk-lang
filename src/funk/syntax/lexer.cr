require "./reader.cr"

module Funk
  class Lexer
    property reader        : Reader
    property filename      : String
    property skip_comments : Bool
    property col, row      : Int32

    def initialize(source : IO, @filename="", @skip_comments=true)
      @reader = Reader.new(source)
      @col, @row = 0, 0
    end

    def self.new(source : String, filename = "", skip_comments = true) : Lexer
      self.new(IO::Memory.new(source), filename, skip_comments)
    end

    def current_char : Char
      reader.current
    end

    def peek : Char
      reader.peek
    end

    def next : Token
      skip_ws

      # Assume its unkown
      tok = Token.new(current_char.to_s, Position.new(col, row, filename), TokenType::Unknown)

      case current_char
      when '\0'
        tok = Token.new("", Position.new(col, row, filename), TokenType::EOF)
      when ';'
        comment   = ""
        start_col = col
        start_row = row

        while current_char != '\n' && current_char != '\0'
          comment += current_char
          consume
        end

        return self.next if skip_comments
        tok = Token.new(comment, Position.new(start_col, start_row, filename), TokenType::Comment)
      when '+'
        tok = operator_or_assign(TokenType::Plus, "+")
      when '-'
        tok = operator_or_assign(TokenType::Minus, "-")
      when '/'
        tok = operator_or_assign(TokenType::Divide, "/")
      when '*'
        case peek
        when '*'
          consume
          tok = operator_or_assign(TokenType::Power, "**")
        else
          tok = operator_or_assign(TokenType::Multiply, "*")
        end
      when '%'
        tok = operator_or_assign(TokenType::Modulus, "%")
      when '='
        tok = operator_or_assign(TokenType::Assignment, "=")
      when '>'
        tok = operator_or_assign(TokenType::GreaterThan, ">")
      when '<'
        tok = operator_or_assign(TokenType::LessThan, "<")
      when '!'
        if peek_is?('=')
          consume
          tok = Token.new("!=", Position.new(col, row, filename), TokenType::NotEqual)
        else
          raise UnexpectedToken.new(message: "Unexpected token: ! #{col}:#{row}")
        end
      when '&'
        if peek_is?('&')
          consume
          tok = Token.new("&&", Position.new(col, row, filename), TokenType::AND)
        else
          raise UnexpectedToken.new(message: "Unexpected token: & #{col}:#{row}")
        end
      when '|'
        if peek_is?('|')
          consume
          tok = Token.new("||", Position.new(col, row, filename), TokenType::OR)
        else
          raise UnexpectedToken.new(message: "Unexpected token: & #{col}:#{row}")
        end
      when '#'
        if peek_is?('t') || peek_is?('T') || peek_is?('f') || peek_is?('F')
          consume
          tok = Token.new("##{current_char}", Position.new(col, row, filename), TokenType::Boolean)
        else
          raise UnexpectedToken.new(message: "Unexpected token: # #{col}:#{row}")
        end
      when '{'
        tok = Token.new("{", Position.new(col, row, filename), TokenType::LeftCurly)
      when '}'
        tok = Token.new("}", Position.new(col, row, filename), TokenType::RightCurly)
      when '('
        tok = Token.new("(", Position.new(col, row, filename), TokenType::LeftParen)
      when ')'
        tok = Token.new(")", Position.new(col, row, filename), TokenType::RightParen)
      when '.'
        tok = Token.new(".", Position.new(col, row, filename), TokenType::Point)
      when '"'
        tok = consume_string
      when '0'..'9'
        tok = consume_numeric
      end

      consume
      tok
    end

    private def consume
      reader.read_char
      @col += 1

      if current_char == '\n'
        @col = 0
        @row += 1
      end
    end

    private def consume_string : Token
      start_col = col
      start_row = row

      consume # opening "
      str = ""

      while current_char != '"' && current_char != Funk::Reader::EOF
        if current_is?('\\')
          consume
          case current_char
          when 'n'
            str += "\n"
          when 't'
            str += "\t"
          when 'r'
            str += "\r"
          else
            raise UnknownEscapeSequence.new("Unknown escape sequence ")
          end
        else
          str += current_char
        end

        consume
      end

      if current_char != '"'
        raise UnexpectedToken.new("Expecting a closing \" found #{current_char} at #{col}:#{row} instead")
      else
        consume # closing "
      end

      Token.new(str, Position.new(col, row, filename), TokenType::String)
    end

    private def operator_or_assign(op : TokenType, raw : String) : Token
      start_col = col
      start_row = row

      if peek_is?('=')
        consume

        case op
        when TokenType::Plus
          return Token.new("+=", Position.new(start_col, start_row, filename), TokenType::PlusAssign)
        when TokenType::Minus
          return Token.new("-=", Position.new(start_col, start_row, filename), TokenType::MinusAssign)
        when TokenType::Divide
          return Token.new("/=", Position.new(start_col, start_row, filename), TokenType::DivideAssign)
        when TokenType::Multiply
          return Token.new("*=", Position.new(start_col, start_row, filename), TokenType::MultiplyAssign)
        when TokenType::Modulus
          return Token.new("%=", Position.new(start_col, start_row, filename), TokenType::ModulusAssign)
        when TokenType::Power
          return Token.new("**=", Position.new(start_col, start_row, filename), TokenType::PowerAssign)
        when TokenType::Assignment
          return Token.new("==", Position.new(start_col, start_row, filename), TokenType::Equal)
        when TokenType::GreaterThan
          return Token.new(">=", Position.new(start_col, start_row, filename), TokenType::GreaterEqual)
        when TokenType::LessThan
          return Token.new(">=", Position.new(start_col, start_row, filename), TokenType::LessEqual)
        end
      end

      Token.new(raw, Position.new(start_col, start_row, filename), op)
    end

    private def skip_ws
      while is_ws?
        consume
      end
    end

    private def peek_is?(val : Char) : Bool
      peek == val
    end

    private def current_is?(val : Char) : Bool
      current_char == val
    end

    private def is_ws? : Bool
      current_char == ' ' || current_char == '\n' || current_char == '\t' || current_char == '\r'
    end

    private def consume_numeric : Token
      numeric = ""
      start_col = col
      start_row = row

      while current_char.number? || (current_is?('.') && peek.number?) || (current_is?('_') && peek.number?)
        numeric += current_char unless current_is?('_') # accept underscore just dont consume it
        consume
      end

      Token.new(numeric, Position.new(start_col, start_row, filename), TokenType::Numeric)
    end
  end

  class UnexpectedToken < Exception
    def initialize(message : String)
      super(message)
    end
  end

  class UnknownEscapeSequence < Exception
    def initialize(message : String)
      super(message)
    end
  end
end
