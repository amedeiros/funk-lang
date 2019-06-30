module Funk
  module Objects
    struct String < Object
      property value : ::String

      def initialize(@value)
      end

      def to_s(io)
        io << value
      end

      def ==(other : Funk::Objects::String) : Funk::Objects::Boolean
        return Funk::VM::TRUE if value == other.value
        Funk::VM::FALSE     
      end
    end
  end
end
