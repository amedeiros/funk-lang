require "./object"

module Funk
  module Objects
    struct Null < Object
      def to_s(io)
        io << nil
      end
    end
  end
end
