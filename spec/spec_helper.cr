require "spec"
require "../src/funk"

def new_parser(code : String) : Funk::Parser
  Funk::Parser.new(Funk::Lexer.new(code))
end
