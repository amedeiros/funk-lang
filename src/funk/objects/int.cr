module Funk
  module Objects
    struct Int < Object
      property value : Int64

      def initialize(@value)
      end

      def to_s(io)
        io << value
      end
    end
  end
end
