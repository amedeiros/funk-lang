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

        lex    = Funk::Lexer.new(response)
        parser = Funk::Parser.new(lex)

        parser.parse!
        if parser.errors.empty?
          puts parser.program.tree
        else
          puts parser.errors.join("\n")
        end
      end
    end

    def prompt
      print "Funk #{count}> "
    end
  end
end

Funk::Repl.run