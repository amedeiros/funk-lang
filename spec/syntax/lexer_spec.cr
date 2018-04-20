require "../spec_helper"

describe Funk::Lexer do
  describe "next" do

    # MISC

    it "should lex EOF" do
      lexer = Funk::Lexer.new("")
      token = lexer.next

      token.type.should eq Funk::TokenType::EOF
    end

    # Operators

    it "should lex a plus sign" do
      token = Funk::Lexer.new("+").next

      token.type.should eq Funk::TokenType::Plus
    end

    it "should lex a minus sign" do
      token = Funk::Lexer.new("-").next

      token.type.should eq Funk::TokenType::Minus
    end

    it "should lex a multiply sign" do
      token = Funk::Lexer.new("*").next

      token.type.should eq Funk::TokenType::Multiply
    end

    it "should lex a divide sign" do
      token = Funk::Lexer.new("/").next

      token.type.should eq Funk::TokenType::Divide
    end

    it "should lex a modulus sign" do
      token = Funk::Lexer.new("%").next

      token.type.should eq Funk::TokenType::Modulus
    end

    it "should lex a power sign" do
      token = Funk::Lexer.new("**").next

      token.type.should eq Funk::TokenType::Power
    end

    it "should lex a assignment" do
      token = Funk::Lexer.new("=").next

      token.type.should eq Funk::TokenType::Assignment
    end

    # Comparison

    it "should lex equals" do
      token = Funk::Lexer.new("==").next

      token.type.should eq Funk::TokenType::Equal
    end

    it "should lex not equals" do
      token = Funk::Lexer.new("!=").next

      token.type.should eq Funk::TokenType::NotEqual
    end

    it "should lex less than" do
      token = Funk::Lexer.new("<").next

      token.type.should eq Funk::TokenType::LessThan
    end

    it "should lex greater than" do
      token = Funk::Lexer.new(">").next

      token.type.should eq Funk::TokenType::GreaterThan
    end

    it "should lex less than equal" do
      token = Funk::Lexer.new("<=").next

      token.type.should eq Funk::TokenType::LessEqual
    end

    it "should lex greater than equal" do
      token = Funk::Lexer.new(">=").next

      token.type.should eq Funk::TokenType::GreaterEqual
    end

    it "should lex and" do
      token = Funk::Lexer.new("&&").next

      token.type.should eq Funk::TokenType::AND
    end

    it "should lex or" do
      token = Funk::Lexer.new("||").next

      token.type.should eq Funk::TokenType::OR
    end

    # Operator assignment

    it "should lex plus assign" do
      token = Funk::Lexer.new("+=").next

      token.type.should eq Funk::TokenType::PlusAssign
    end

    it "should lex minus assign" do
      token = Funk::Lexer.new("-=").next

      token.type.should eq Funk::TokenType::MinusAssign
    end

    it "should lex multiply assign" do
      token = Funk::Lexer.new("*=").next

      token.type.should eq Funk::TokenType::MultiplyAssign
    end

    it "should lex divide assign" do
      token = Funk::Lexer.new("/=").next

      token.type.should eq Funk::TokenType::DivideAssign
    end

    it "should lex modulus assign" do
      token = Funk::Lexer.new("%=").next

      token.type.should eq Funk::TokenType::ModulusAssign
    end

    it "should lex power assign" do
      token = Funk::Lexer.new("**=").next

      token.type.should eq Funk::TokenType::PowerAssign
    end

    # Structure

    it "should lex left curly" do
      token = Funk::Lexer.new("{").next

      token.type.should eq Funk::TokenType::LeftCurly
    end

    it "should lex right curly" do
      token = Funk::Lexer.new("}").next

      token.type.should eq Funk::TokenType::RightCurly
    end

    it "should lex left paren" do
      token = Funk::Lexer.new("(").next

      token.type.should eq Funk::TokenType::LeftParen
    end

    it "should lex right paren" do
      token = Funk::Lexer.new(")").next

      token.type.should eq Funk::TokenType::RightParen
    end

    it "should skip comments" do
      token = Funk::Lexer.new("; this is a comment").next

      token.type.should eq Funk::TokenType::EOF
    end

    it "should lex comments" do
      token = Funk::Lexer.new("; this is a comment", skip_comments: false).next

      token.type.should eq Funk::TokenType::Comment
    end

    it "should lex a point" do
      token = Funk::Lexer.new(".").next

      token.type.should eq Funk::TokenType::Point
    end

    # Literals

    ["#f", "#F", "#t", "#T"].each do |bool|
      it "should lex #{bool} boolean" do
        token = Funk::Lexer.new(bool).next

        token.type.should eq Funk::TokenType::Boolean
      end
    end

    it "should lex a number" do
      token = Funk::Lexer.new("123_345.456").next
      token.type.should eq Funk::TokenType::Numeric
      token.raw.should eq "123345.456"
    end

    it "should lex a string" do
      val = "Some words 1234 !@#$%^&*() \n\t\r  "
      str = "\"#{val}\""
      token = Funk::Lexer.new(str).next

      token.type.should eq Funk::TokenType::String
      token.raw.should eq val
    end

    Funk::Lexer::KEYWORDS.each do |keyword|
      it "should lex keyword #{keyword}" do
        token = Funk::Lexer.new(keyword).next

        token.type.should eq Funk::TokenType::Keyword
        token.raw.should eq keyword
      end
    end

    ["ident_test", "key?", "save!", "ident"].each do |ident|
      it "should lex identifier #{ident}" do
        token = Funk::Lexer.new(ident).next

        token.type.should eq Funk::TokenType::Identifier
        token.raw.should eq ident
      end
    end

    it "should lex multiple tokens" do
      lexer = Funk::Lexer.new("+ -")
      token = lexer.next
      token.type.should eq Funk::TokenType::Plus
      token_two = lexer.next
      token_two.type.should eq Funk::TokenType::Minus
    end

    it "should lex an unkown token" do
      token = Funk::Lexer.new("@").next

      token.type.should eq Funk::TokenType::Unknown
    end
  end
end