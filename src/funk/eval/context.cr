module Funk
  class Context
    property invoking_context : Funk::Context | Nil
    property metadata         : Funk::Objects::Closure
    property return_ip        : Int32
    property return_code      : Array(Int32)
    property locals           : Array(Funk::Objects::Object)

    def initialize(@invoking_context, @return_ip, @metadata, @return_code = Array(Int32).new)
      @locals = Array(Funk::Objects::Object).new(metadata.compiled_function.nargs + metadata.compiled_function.nlocals)
    end
  end
end
