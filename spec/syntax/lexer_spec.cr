require "../spec_helper"

describe Funk::Lexer do
  describe "next" do
    it "should lex EOF" do
      lexer = Funk::Lexer.new("+")
      lexer.next # +
      token = lexer.next

      token.type.should eq Funk::TokenType::EOF
    end

    # it "should lex a plus sign" do
    #   token = Funk::Lexer.new("+").next

    #   token.type.should eq Funk::TokenType::Plus
    # end
  end
end