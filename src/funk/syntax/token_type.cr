module Funk
  enum TokenType
    # Literals
    Numeric
    Boolean
    String
    Identifier
    
    # Keywords
    Def
    If
    ElsIf
    Else
    Unless
    While
    Until
    Class
    Return
    Break
    Continue
    Lambda

    # Operators
    Plus
    Minus
    Multiply
    Divide
    Modulus
    Power
    Assignment
    Bang

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
    Comma

    # Misc
    EOF
    Unknown
  end
end