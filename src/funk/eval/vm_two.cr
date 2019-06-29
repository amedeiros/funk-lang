require "../objects/*"

module Funk
  class VMTwo
    STACK_SIZE  = 2_048
    GLOBAL_SIZE = 65_536
    MAX_FRAMES  = 1_024

    TRUE  = Funk::Objects::Boolean.new(true)
    FALSE = Funk::Objects::Boolean.new(false)
    NULL  = Funk::Objects::Null.new
  end
end