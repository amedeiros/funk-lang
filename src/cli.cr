require "./funk"

require "option_parser"
require "file"

compile = ""
displayed_help = false

parser = OptionParser.parse! do |parser|
  parser.banner = "Usage: cli [options] [file]"
  parser.on("-c NAME", "--compile=NAME", "Compile to scheme!") { |name| compile = name }
  parser.on("-h", "--help", "Show this help") { displayed_help = true; puts parser }
end

unless compile.empty?
  printer  = Funk::AstSchemePrinter.new
  code     = File.open(compile)
  lex      = Funk::Lexer.new(code, compile)
  parser   = Funk::Parser.new(lex)

  puts printer.visit_program(parser.parse!.program)
else
  puts parser unless displayed_help
end

