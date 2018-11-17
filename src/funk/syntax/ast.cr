module Funk
  abstract class Ast
    property position : Position?

    def at(@position)
      self
    end
  end

  macro node(name, *properties)
    class {{name.id}} < Ast
    {% for prop in properties %}
      property {{prop.id}}
    {% end %}

      def initialize({{
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
  node Numeric,    token : Token, value : Float64
  node StringNode, token : Token, value : String
  node Identifier, token : Token, value : String
  node Keyword,    value : String
  node Boolean,    token : Token, value : Bool

  node PrefixExpression, token : Token, operator : String, right : Ast
  node InfixExpression, token : Token, left : Ast, operator : TokenType, right : Ast
  node Assignment, left  : Identifier, right : Ast

  node IfExpression,
    token : Token,
    cond : Ast,
    consequence : Block,
    alternative : Ast | Nil
  
  # node ClassStatement,
  #   name : Identifier,
  #   body : Block

  node ReturnStatement, token : Token, expression : Ast
  node DefStatement, token : Token, name : Identifier, value : Ast
  node Lambda, token : Token, parameters : Array(Ast), body : Block
  node Block, token : Token, statements : Array(Ast)
  node ExpressionStatement, token : Token, expression : Ast

  node Null
  node LeftCurly
  node RightCurly
  node LeftParen
  node RightParen
end
