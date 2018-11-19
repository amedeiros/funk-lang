module Funk
  class AstSchemePrinter < Visitor(String)
    def visit_program(exp : Funk::Program) : String
      prog = ""
      exp.tree.each { |x| prog += x.accept(self) }
      prog
    end

    def visit_numeric(exp : Funk::Numeric) : String
      exp.value.to_s
    end

    def visit_string_node(exp : Funk::StringNode) : String
      exp.value
    end

    def visit_identifier(exp : Funk::Identifier) : String
      exp.value
    end

    def visit_boolean(exp : Funk::Boolean) : String
      exp.value ? "#t" : "#f"
    end

    def visit_prefix_expression(exp : Funk::PrefixExpression) : String
      case exp.operator
      when "!"
        parenthesize("not", exp.right)
      else
        parenthesize(exp.operator, exp.right)
      end
    end

    def visit_infix_expression(exp : Funk::InfixExpression) : String
      parenthesize(exp.token.raw, exp.left, exp.right)
    end

    def visit_if_expression(exp : Funk::IfExpression) : String
      cond = exp.cond.accept(self)
      cond_statement = parenthesize("cond (#{cond}", exp.consequence)
      alt = exp.alternative.as(Funk::IfExpression)

      while alt.is_a?(Funk::IfExpression)
        # Else check
        if alt.cond.is_a?(Funk::Null)
          cond_statement += parenthesize("else", alt.consequence)
        else
          cond = alt.cond.accept(self)
          cond_statement += parenthesize("#{cond}", alt.consequence)
        end

        alt = alt.alternative
      end

      cond_statement + ")"
    end

    def visit_return_statement(exp : Funk::ReturnStatement) : String
      exp.expression.accept(self)
    end

    def visit_def_statement(exp : Funk::DefStatement) : String
      parenthesize("define " + exp.name.accept(self), exp.value)
    end

    def visit_lambda(exp : Funk::Lambda) : String
      parenthesize("lambda #{parenthesize("", exp.parameters)}", exp.body)
    end

    def visit_block(exp : Funk::Block) : String
      exp.statements.map { |x| x.accept(self) }.join("")
    end

    def visit_expression_statement(exp : Funk::ExpressionStatement) : String
      exp.expression.accept(self)
    end

    def visit_null(exp : Funk::Null) : String
      "()"
    end

    def visit_call_expression(exp : Funk::CallExpression) : String
      parenthesize(exp.name.accept(self), exp.arguments)
    end

    private def parenthesize(name : String, *exprs) : String
      parenthesize(name, exprs.to_a)
    end

    private def parenthesize(name : String, exprs : Array(Ast)) : String
      prog = "(#{name}"
      exprs.each { |x| prog += " #{x.accept(self)}"}
      prog += ")"
    end
  end
end
