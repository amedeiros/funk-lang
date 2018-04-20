module Funk
  class UnknownEscapeSequence < Exception
    def initialize(message : String)
      super(message)
    end
  end
end
