module Funk
  class UnexpectedToken < Exception
    def initialize(message : String)
      super(message)
    end
  end
end