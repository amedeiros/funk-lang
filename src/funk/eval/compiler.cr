module Funk
  class Compiler < Visitor(Array(Int32))
    property string_table   = Array(Funk::Objects::String).new
    property function_table = { "display" => 0 }
    property func_meta      = [Funk::Objects::Closure.new(Funk::Objects::CompiledFunction.new([Funk::Bytecode::PRINT, Funk::Bytecode::RET]), "PRINT")]
    property code           = Array(Int32).new
    property constants      = Array(Funk::Objects::Object).new

    def visit_program(exp : Funk::Program) : Array(Int32)
      @code = Array(Int32).new

      exp.tree.each do |x|
        @code += x.accept(self)
      end

      code << Bytecode::HALT

      code
    end

    def visit_numeric(exp : Funk::Numeric) : Array(Int32)
      [Bytecode::ICONST, exp.value.to_i32]
    end

    def visit_null(exp : Funk::Null) : Array(Int32)
      [Bytecode::NULL]
    end

    def visit_string_node(exp : Funk::StringNode) : Array(Int32)
      code = [Bytecode::STRING, string_table.size]
      string_table << Funk::Objects::String.new(exp.value)
      code
    end

    def visit_identifier(exp : Funk::Identifier) :  Array(Int32)
      [] of Int32
    end

    def visit_boolean(exp : Funk::Boolean) :  Array(Int32)
      [Bytecode::BOOL, exp.value ? 1 : 0]
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
      when TokenType::Multiply
        code << Bytecode::IMUL
      when TokenType::Minus
        code << Bytecode::ISUB
      when TokenType::LessThan
        code << Bytecode::ILT
      when TokenType::GreaterThan
        code << Bytecode::IGT
      when TokenType::Equal
        code << Bytecode::IEQ
      when TokenType::GreaterEqual
        code << Bytecode::IGTEQ
      when TokenType::LessEqual
        code << Bytecode::ILTEQ
      else
        raise Funk::Errors::RuntimeError.new("Unkown operator #{exp.operator}")
      end

      code
    end

    def visit_if_expression(exp : Funk::IfExpression) : Array(Int32)
      [] of Int32
    end

    def visit_return_statement(exp : Funk::ReturnStatement) : Array(Int32)
      exp.expression.accept(self)
    end

    def visit_def_statement(exp : Funk::DefStatement) : Array(Int32)
      code = [] of Int32
      case exp.value
      when Funk::Lambda
        lambda = exp.value.as(Funk::Lambda)
        lambda.accept(self)
        # @func_meta << Funk::FunctionMeta.new(exp.name.value, lambda.parameters.size - 1, 0, code.size)
        # @function_table[exp.name.value] = code.size

        # # lambda.parameters.each_with_index { |v, i| code += [Bytecode::LOAD, i] }

        # code += lambda.body.accept(self)
        # code << Bytecode::RET
      else
        raise Funk::Errors::RuntimeError.new("Not implemeted!")
      end

      code
    end

    def visit_lambda(exp : Funk::Lambda) : Array(Int32)
      raise "LAMBDA IMPLEMENT"
      [] of Int32
    end

    def visit_block(exp : Funk::Block) : Array(Int32)
      exp.statements.map { |x| x.accept(self) }.flatten
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