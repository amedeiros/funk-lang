module Funk
  module Errors
    class StandardError < Exception end
    class SyntaxError < StandardError end
    class UnexpectedToken < StandardError end
    class UnknownEscapeSequence < StandardError end
    class RuntimeError < StandardError end
    class CompiletimeError < StandardError end
  end
end
