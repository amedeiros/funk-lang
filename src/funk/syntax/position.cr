module Funk
  class Position
    getter col, row : Int32
    property filename : String

    def initialize(@col : Int32, @row : Int32, @filename="")
    end

    def to_s(io)
      io << "#{row}:#{col} #{filename}"
    end
  end
end
