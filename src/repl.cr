require "./funk"

module Funk
  class Repl
    property count : Int32 = -1

    def self.run
      Repl.new.run
    end

    def run
      response = ""
      verbose  = ENV.has_key?("VERBOSE")
      vm       = Funk::VM.new(verbose)
      compiler = Funk::Compiler.new

      while response != "exit"
        prompt
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

    def prompt
      @count += 1
      print "Funk #{count}> "
    end

    def print_exception(exc : Exception, msg : String = "")
      puts msg unless msg.empty?
      puts exc
      puts exc.backtrace.join("\n")
    end
  end
end

Funk::Repl.run