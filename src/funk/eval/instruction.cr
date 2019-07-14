module Funk
  struct Instruction
    property name  : String
    property operand_width : Array(Int32)

    def initialize(@name : String, @operand_width : Array(Int32) = Array(Int32).new)
    end
  end
end
