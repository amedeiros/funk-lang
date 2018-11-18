require "../spec_helper"

describe Funk::Parser do
  describe "parse!" do
    it "should parse concatination" do
      left = "\"left\""
      right = "\"left\""
      parser = new_parser("#{left} +#{right}").parse!
      exp = parser.program.tree[0].as(Funk::ExpressionStatement).expression.as(Funk::InfixExpression)
      exp.left.token.type.should eq Funk::TokenType::String
      exp.left.token.raw.should  eq left
      exp.right.token.type.should eq Funk::TokenType::String
      exp.right.token.raw.should  eq right
    end

    it "should parse a number" do
      parser = new_parser("100").parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Numeric
    end

    it "should parse a negative number" do
      parser = new_parser("-100").parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Numeric
    end

    it "should parse booleans" do
      ["#T", "#f"].each do |bool|
        parser = new_parser(bool).parse!

        exp = parser.program.tree[0].as(Funk::ExpressionStatement)
        exp.token.type.should eq Funk::TokenType::Boolean
        exp.expression.as(Funk::Boolean).value.should eq (bool == "#T")
      end
    end

    it "should parse a identifier" do
      parser = new_parser("ident").parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Identifier
    end

    it "should parse a def statement" do
      parser = new_parser("def a = 1").parse!
      exp = parser.program.tree[0].as(Funk::DefStatement)

      exp.name.token.type.should eq Funk::TokenType::Identifier
      exp.name.value.should eq "a" 

      num = exp.value.as(Funk::Numeric)
      num.token.type.should eq Funk::TokenType::Numeric
      num.value.should eq 1
    end

    it "should parse a string" do
      val    = "\"string\""
      parser = new_parser(val).parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::String
      exp.expression.as(Funk::StringNode).value.should eq val
    end

    # syntax errors

    it "should raise an error for a number followed by a unexpected token" do
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 2").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 #t").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 ident").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 \"string\"").parse! }
    end

    it "should raise an error for a string followed by a unexpected token" do
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" \"another\"").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" #t").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" ident").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" 1").parse! }
    end

    it "should raise an error for a boolean followed by a unexpected token" do
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t #F").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t 100").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t ident").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t \"string\"").parse! }
    end

    it "should raise an error for a negative sign - not followed by a numeric" do
      ["-\"string\"", "-#t"].each do |x|
        expect_raises(Funk::Errors::SyntaxError) { new_parser("-#{x}").parse! }
      end
    end

    it "should raise concat errors" do
      string = "\"string\""
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#{string} + 1").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 + #{string}").parse! }
    end
  end
end