require "./funk"

module Funk
  class Repl
    property count : Int32 = 0

    def self.run
      Repl.new.run
    end

    def run
      response = ""

      while response != "exit"
        prompt
        response = gets
        response = response.chomp.to_s if response
        response ||= ""

        begin
          lex    = Funk::Lexer.new(response)
          parser = Funk::Parser.new(lex)

          parser.parse!
          puts parser.program.tree
        rescue exc : Funk::Errors::StandardError
          puts exc
        end
      end
    end

    def prompt
      print "Funk #{count}> "
    end
  end
end

Funk::Repl.run