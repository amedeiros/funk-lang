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
    end
  end
end