module Funk
  module Objects
    struct Null < Object
      def to_s(io)
        io << nil
      end

      def ==(other : Funk::Objects::Null) : Funk::Objects::Boolean
        Funk::VM::TRUE
      end
    end
  end
end
