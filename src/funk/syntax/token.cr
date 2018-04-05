require "./token_type.cr"
require "./position"

module Funk
  class Token
    getter type     : TokenType
    getter raw      : String
    getter position : Position

    def initialize(@raw : String, @position = position, @type = TokenType::Unknown)
    end

    def to_s(io)
      io << self.type << ", " << raw << " " << position
    end
  end
end