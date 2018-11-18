module Funk
  abstract class Ast
    property token : Token

    def initialize(@token : Token) end
  end

  macro node(name, *properties)
    class {{name.id}} < Ast
    {% for prop in properties %}
      property {{prop.id}}
    {% end %}

      def initialize(@token : Token, {{
                        *properties.map do |field|
                          "@#{field.var}".id
                        end
                      }})
      end
    end
  end

  # Program
  node Program, tree : Array(Ast)

  # Litterals
  node Numeric,    value : Float64
  node StringNode, value : String
  node Identifier, value : String
  node Boolean,    value : Bool

  node PrefixExpression, operator : String, right : Ast
  node InfixExpression, left : Ast, operator : TokenType, right : Ast
  node Assignment, left  : Identifier, right : Ast

  node IfExpression,
    cond : Ast,
    consequence : Block,
    alternative : Ast

  node ReturnStatement, expression : Ast
  node DefStatement, name : Identifier, value : Ast
  node Lambda, parameters : Array(Ast), body : Block
  node Block, statements : Array(Ast)
  node ExpressionStatement, expression : Ast

  node Null
  node LeftCurly
  node RightCurly
  node LeftParen
  node RightParen
end
