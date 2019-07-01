require "spec"
require "../src/funk"

def new_parser(code : String) : Funk::Parser
  Funk::Parser.new(Funk::Lexer.new(code))
end

def compile(code : String) : Array(Int32)
  Funk::Compiler.new.visit_program(new_parser(code).parse!.program)
end
