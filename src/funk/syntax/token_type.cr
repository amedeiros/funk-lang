module Funk
  enum TokenType
    # Literals
    Numeric
    Boolean
    String
    Identifier
    Keyword

    # Operators
    Plus
    Minus
    Multiply
    Divide
    Modulus
    Power
    Assignment

    # Comparison
    Equal
    NotEqual
    LessThan
    GreaterThan
    LessEqual
    GreaterEqual
    AND
    OR

    # Operator assignment
    PlusAssign
    MinusAssign
    MultiplyAssign
    DivideAssign
    ModulusAssign
    PowerAssign

    # Structure
    LeftCurly
    RightCurly
    LeftParen
    RightParen
    Comment
    Point

    # Misc
    EOF
    Unknown
  end
end