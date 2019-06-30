module Funk
  module Objects
    struct String < Object
      property value : ::String

      def initialize(@value)
      end

      def to_s(io)
        io << value
      end
    end
  end
end