require "./object"

module Funk
  module Objects
    struct Boolean < Object
      property value : Bool

      def initialize(@value)
      end

      def to_s(io)
        io << (value ? "#t" : "#f")
      end

      def ==(other : Funk::Objects::Boolean) : Funk::Objects::Boolean
        return Funk::VM::TRUE if value == other.value
        Funk::VM::FALSE     
      end
    end
  end
end