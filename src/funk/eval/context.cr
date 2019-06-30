module Funk
  class Context
    property invoking_context : Funk::Context | Nil
    property metadata         : Funk::Objects::Closure
    property return_ip        : Int32
    property return_code      : Array(Int32)
    property locals = Array(Funk::Objects::Object).new

    def initialize(@invoking_context, @return_ip, @metadata, @return_code = Array(Int32).new)
    end
  end
end
