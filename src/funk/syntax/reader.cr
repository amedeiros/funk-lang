module Funk
  class Reader
    property source  : File | IO::Memory
    property buffer  : IO::Memory
    property pos     : Int32
    property current : Char

    EOF = '\0'

    def initialize(@source)
      @pos     = 0
      @buffer  = IO::Memory.new
      @current = EOF
      read_char
    end

    def self.new(source : String) : Reader
      self.new(IO::Memory.new(source))
    end

    def read_char : Char
      char = source.read_char
      char = EOF unless char.is_a?(Char)
      puts char

      @pos += 1
      @current = char
      @buffer  << char

      current
    end

    def peek : Char
      char = source.read_char
      char = EOF unless char.is_a?(Char)

      source.pos -= 1 unless source.size == 0

      char
    end

    # Fill the buffer
    def finalize!
      until current == EOF
        read_char
      end
    end
  end
end