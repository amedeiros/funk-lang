module Funk
  module Objects
    struct Int < Object
      property value : Int64

      def initialize(@value)
      end

      def to_s(io)
        io << value
      end

      def ==(other : Int) : Funk::Objects::Boolean
        return Funk::VM::TRUE if value == other.value
        Funk::VM::FALSE     
      end
    end
  end
end
