require "./object"

module Funk
  module Objects
    struct Boolean < Object
      property value : Bool

      def initialize(@value)
      end
    end
  end
end