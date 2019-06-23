module Funk
  class Compiler < Visitor(Array(Int32))
    property string_table   = Array(String).new
    property function_table = { "display" => 1 }

    def visit_program(exp : Funk::Program) : Array(Int32)
      prog = Array(Int32).new
      exp.tree.each do |x| 
        prog += x.accept(self)
      end

      prog << Bytecode::HALT

      prog
    end

    def visit_numeric(exp : Funk::Numeric) : Array(Int32)
      [Bytecode::ICONST, exp.value.to_i32]
    end

    def visit_null(exp : Funk::Null) : Array(Int32)
      [Bytecode::NULL]
    end

    def visit_string_node(exp : Funk::StringNode) : Array(Int32)
      string_table << exp.value
      [Bytecode::STRING, string_table.size]
    end

    def visit_identifier(exp : Funk::Identifier) :  Array(Int32)
      [] of Int32
    end

    def visit_boolean(exp : Funk::Boolean) :  Array(Int32)
      [Bytecode::BOOL, exp.value ? VM::TRUE : VM::FALSE]
    end

    def visit_prefix_expression(exp : Funk::PrefixExpression) : Array(Int32)
      [] of Int32
    end

    def visit_infix_expression(exp : Funk::InfixExpression) : Array(Int32)
      code = [] of Int32
      code += exp.left.accept(self)
      code += exp.right.accept(self)

      case exp.operator
      when TokenType::Plus
        code << Bytecode::IADD
      end

      code << Bytecode::PRINT
      
      code
    end

    def visit_if_expression(exp : Funk::IfExpression) : Array(Int32)
      [] of Int32
    end

    def visit_return_statement(exp : Funk::ReturnStatement) : Array(Int32)
      [] of Int32
    end

    def visit_def_statement(exp : Funk::DefStatement) : Array(Int32)
      [] of Int32
    end

    def visit_lambda(exp : Funk::Lambda) : Array(Int32)
      [] of Int32
    end

    def visit_block(exp : Funk::Block) : Array(Int32)
      [] of Int32
    end

    def visit_expression_statement(exp : Funk::ExpressionStatement) : Array(Int32)
      exp.expression.accept(self)
    end

    def visit_call_expression(exp : Funk::CallExpression) : Array(Int32)
      if function_table.has_key?(exp.name.value)
        func = Array(Int32).new
        exp.arguments.each { |x| func += x.accept(self) }
        func << Bytecode::CALL
        func << function_table[exp.name.value]

        # exp.arguments.each { |x| func += x.accept(self) }
        # puts func
        func
      else
        raise Funk::Errors::RuntimeError.new("Unknown function #{exp.name}")
      end
    end

    def visit_while_statement(exp : Funk::WhileStatement) : Array(Int32)
      [] of Int32
    end
  end
end