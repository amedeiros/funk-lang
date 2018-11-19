require "./funk"

module Funk
  class Repl
    property count : Int32 = 0

    def self.run
      Repl.new.run
    end

    def run
      response = ""
      printer  = Funk::AstSchemePrinter.new

      while response != "exit"
        prompt
        response = gets
        response = response.chomp.to_s if response
        response ||= ""

        begin
          lex    = Funk::Lexer.new(response)
          parser = Funk::Parser.new(lex)

          puts printer.visit_program(parser.parse!.program)
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