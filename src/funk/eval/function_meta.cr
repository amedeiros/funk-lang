module Funk
  struct FunctionMeta
    property name : String
    property nargs : Int32
    property nlocals : Int32
    property address : Int32

    def initialize(@name, @nargs, @nlocals, @address)
    end
  end
end
