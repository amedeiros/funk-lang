module Funk
  class Reader
    property source  : IO
    property buffer  : IO::Memory
    property pos     : Int32
    property current : Char

    EOF = '\0'

    def initialize(@source)
      @pos     = 0
      @buffer  = IO::Memory.new
      @current = prime
    end

    def self.new(source : String) : Reader
      self.new(IO::Memory.new(source))
    end

    def read_char : Char
      char = source.read_char
      char = EOF unless char

      @pos += 1
      @current = char
      @buffer  << char

      current
    end

    def peek : Char
      char = source.read_char

      unless char
        char = EOF
      else
        source.pos -= 1
      end

      char
    end

    # Fill the buffer
    def finalize!
      until current == EOF
        read_char
      end
    end

    private def prime : Char
      char = source.read_char
      char = EOF unless char
      char
    end
  end
end