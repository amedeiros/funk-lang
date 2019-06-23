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
  compiler = Funk::Compiler.new
  code     = File.open(compile)
  lex      = Funk::Lexer.new(code, compile)
  parser   = Funk::Parser.new(lex)

  bytecode = compiler.visit_program(parser.parse!.program)
  func_table = [Funk::FunctionMeta.new("main", 0, 0, 0)]
  vm = Funk::VM.new(bytecode, Array(Int32).new, func_table)
  vm.trace = true
  vm.exec(func_table[0].address)
else
  puts parser unless displayed_help
end

