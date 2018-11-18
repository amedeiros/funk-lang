module Funk
  module Errors
    class StandardError < Exception end
    class SyntaxError < StandardError end
    class UnexpectedToken < StandardError end
  end
end
