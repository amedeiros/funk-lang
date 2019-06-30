require "./funk"

require "option_parser"
require "file"

compile = ""
displayed_help = false
verbose = false

parser = OptionParser.parse! do |parser|
  parser.banner = "Usage: cli [options] [file]"
  parser.on("-c NAME", "--compile=NAME", "Compile to scheme!") { |name| compile = name }
  parser.on("-v", "--verbose", "Show VM internals") { verbose = true }
  parser.on("-h", "--help", "Show this help") { displayed_help = true; puts parser }
end

unless compile.empty?
  compiler = Funk::Compiler.new
  code     = File.open(compile)
  lex      = Funk::Lexer.new(code, compile)
  parser   = Funk::Parser.new(lex)

  bytecode = compiler.visit_program(parser.parse!.program)
  vm       = Funk::VM.new(verbose)
  vm.code         = compiler.visit_program(parser.parse!.program)
  vm.metadata     = compiler.func_meta
  vm.string_table = compiler.string_table
  vm.exec(0)
  val = vm.last_popped_stack

  if val != nil
    puts val 
  end
else
  puts parser unless displayed_help
end

