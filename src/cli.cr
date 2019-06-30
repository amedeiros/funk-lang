require "./funk"

require "option_parser"
require "file"

compile        = ""
repl           = false
displayed_help = false
verbose        = false

parser = OptionParser.parse! do |parser|
  parser.banner = "Usage: cli [options] [file]"
  parser.on("-c NAME", "--compile=NAME", "Compile to scheme!") { |name| compile = name }
  parser.on("-v", "--verbose", "Show VM internals") { verbose = true }
  parser.on("-h", "--help", "Show this help") { displayed_help = true; puts parser }
  parser.on("-r", "--repl", "Run the repl") { repl = true }
end

if !compile.empty?
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
elsif repl
  run_repl(verbose)
else
  puts parser unless displayed_help
end

def run_repl(verbose)
  response = ""
  vm       = Funk::VM.new(verbose)
  compiler = Funk::Compiler.new
  count    = 0

  while response != "exit"
    print "Funk #{count}> "
    count += 1
    response = gets
    response = response.chomp.to_s if response
    response ||= ""
    break if response == "exit"

    begin
      lex     = Funk::Lexer.new(response)
      parser  = Funk::Parser.new(lex)
      vm.code = compiler.visit_program(parser.parse!.program)
      vm.metadata = compiler.func_meta
      vm.string_table = compiler.string_table
      vm.exec(0)
      val = vm.last_popped_stack
      if val != nil
        puts val 
      end
    rescue exc : Funk::Errors::StandardError
      print_exception(exc)
    rescue exc : Exception
      print_exception(exc, "Found a bug in Funk!")
    end
  end
end

def print_exception(exc : Exception, msg : String = "")
  puts msg unless msg.empty?
  puts exc
  puts exc.backtrace.join("\n")
end

