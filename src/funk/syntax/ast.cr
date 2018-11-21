module Funk
  abstract class Ast
    property token : Token

    def initialize(@token : Token) end
  end

  abstract class Visitor(T) end

  macro node(name, *properties)
    abstract class Funk::Visitor(T)
      abstract def visit_{{name.id.underscore.downcase}}(exp : {{name.id}}) : T
    end

    class {{name.id}} < Ast
    {% for prop in properties %}
      property {{prop.id}}
    {% end %}

      def accept(visitor : Visitor)
        visitor.visit_{{name.id.underscore.downcase}}(self)
      end

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
  node Null

  # Litterals
  node Numeric,    value : Float64
  node StringNode, value : String
  node Identifier, value : String
  node Boolean,    value : Bool

  node CallExpression, name : Identifier, arguments : Array(Ast)
  node PrefixExpression, operator : String, right : Ast
  node InfixExpression, left : Ast, operator : TokenType, right : Ast
  node IfExpression, cond : Ast, consequence : Block, alternative : Ast

  node WhileStatement, cond : Ast, body : Ast
  node ReturnStatement, expression : Ast
  node DefStatement, name : Identifier, value : Ast
  node Lambda, parameters : Array(Ast), body : Block
  node Block, statements : Array(Ast)
  node ExpressionStatement, expression : Ast
end
