module Funk
  module Objects
    struct CompiledFunction
      property code     : Array(Int32)
      property nlocals : Int32
      property nargs   : Int32

      def initialize(@code, @nlocals = 0, @nargs = 0)
      end
    end

    struct Closure < Object
      property! free : Array(Object)
      property compiled_function : CompiledFunction
      property  name    : ::String

      def initialize(@compiled_function, @name = "<Closure>")
      end
    end
  end
end
