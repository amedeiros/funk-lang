module Funk
  struct Instruction
    property name  : String
    property nargs : Int32

    def initialize(@name : String, @nargs : Int32 = 0)
    end
  end
end
