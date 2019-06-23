module Funk
  class Context
    property invoking_context : Funk::Context | Nil
    property metadata         : FunctionMeta
    property return_ip        : Int32
    property locals           : Array(Int32)

    def initialize(@invoking_context, @return_ip, @metadata)
      @locals = Array(Int32).new(metadata.nargs + metadata.nlocals)
    end
  end
end
