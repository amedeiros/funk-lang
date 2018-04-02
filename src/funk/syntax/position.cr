module Funk
  class Position
    getter col, row : Int32
    property filename : String

    def initialize(@col : Int32, @row : Int32, @filename="")
    end
  end
end
