module Funk
  struct EmittedInstruction
    property! op_code : Bytecode
    property! position : Int32
  end

  struct CompliationScope
    property instructions : Array(Bytes) = Array(Bytes).new
    property last_instruction : EmittedInstruction = EmittedInstruction.new
    property previous_instruction : EmittedInstruction = EmittedInstruction.new

    def initialize(@instructions, @last_instruction, @previous_instruction)
    end

    def initialize
    end
  end

  class Compiler # < Visitor(Array(Bytes))
    property constants      = Array(Funk::Objects::Object).new
    property symbol_table   = Funk::SymbolTable.new
    property scopes         = Array(CompliationScope)
    property scope_index    = 0

    def initialize
      main_scope = CompliationScope.new(instructions: Array.new())
    end

    def compile(exp : Funk::Ast)
      case exp
      when Funk::Program
        exp.tree.each { |x| compile(x) }
      when Funk::ExpressionStatement
        compile(exp.expression)
        emit(Bytecode::POP)
      when Funk::InfixExpression
        compile(exp.left)
        compile(exp.right)

        case exp.operator
        when TokenType::Plus
          code << emit(Bytecode::ADD, 0)
        when TokenType::Multiply
          code << emit(Bytecode::MUL, 0)
        when TokenType::Minus
          code << emit(Bytecode::SUB, 0)
        when TokenType::LessThan
          code << emit(Bytecode::LT, 0)
        when TokenType::GreaterThan
          code << emit(Bytecode::GT, 0)
        when TokenType::Equal
          code << emit(Bytecode::EQ, 0)
        when TokenType::GreaterEqual
          code << emit(Bytecode::GTEQ, 0)
        when TokenType::LessEqual
          code << emit(Bytecode::LTEQ, 0)
        when TokenType::Divide
          code << emit(Bytecode::DIV, 0)
        else
          raise Funk::Errors::CompiletimeError.new("Unkown operator #{exp.operator}")
        end
      when Funk::Numeric
        emit(Bytecode::CONSTANT, add_constant(Funk::Objects::Int.new(exp.value)))
      when Funk::Null
        emit(Bytecode::NULL, 0)
      end
    end

    def visit_null(exp : Funk::Null) : Array(Bytes)
      make(Bytecode::NULL, 0)
    end

    def visit_string_node(exp : Funk::StringNode) : Array(Bytes)
      make(Bytecode::CONSTANT, add_constant(Funk::Objects::String.new(exp.value)))
    end

    def visit_identifier(exp : Funk::Identifier) : Array(Bytes)
      symbol = symbol_table.resolve(exp.value)
      raise Funk::Errors::CompiletimeError.new("Undefined variable #{exp.value}") unless symbol

      load_symbol(symbol)
    end

    def visit_boolean(exp : Funk::Boolean) :  Array(Bytes)
      if exp.value == 1
        make(Bytecode::TRUE, 0)
      else
        make(Bytecode::FALSE, 0)
      end
    end

    def visit_prefix_expression(exp : Funk::PrefixExpression) : Array(Bytes)
      [] of Int32
    end

    def visit_if_expression(exp : Funk::IfExpression) : Array(Bytes)
      [] of Bytes
    end

    def visit_return_statement(exp : Funk::ReturnStatement) : Array(Bytes)
      exp.expression.accept(self)
      make(Bytecode::RET, 0)
    end

    def visit_def_statement(exp : Funk::DefStatement) : Array(Bytes)
      symbol = symbol_table.define(exp.name.value)
      code   = exp.value.accept(self)
      
      if symbol.scope == Funk::SymbolTable::GLOBAL_SCOPE
        code += make(Bytecode::GSTORE, symbol.index)
      else
        code += make(Bytecode::STORE, symbol.index)
      end

      code
    end

    def visit_lambda(exp : Funk::Lambda) : Array(Bytes)
      enter_scope
      exp.parameters.each { |x| symbol_table.define(p.value)}
      code = exp.body.accept(self)

      if last_instruction_is?(Bytecode::POP)
        replace_last_pop_with_return
      end

      if !last_instruction(Bytecode::RET)
        code += make(Bytecode::RET, 0)
      end
    end

    def visit_block(exp : Funk::Block) : Array(Bytes)
      exp.statements.map { |x| x.accept(self) }.flatten
    end

    def visit_call_expression(exp : Funk::CallExpression) : Array(Bytes)
      if function_table.has_key?(exp.name.value)
        func = Array(Bytes).new
        exp.arguments.each { |x| func += x.accept(self) }
        func << Bytecode::CALL
        func << function_table[exp.name.value]

        func
      else
        raise Funk::Errors::RuntimeError.new("Unknown function #{exp.name}")
      end
    end

    def visit_while_statement(exp : Funk::WhileStatement) : Array(Bytes)
      [] of Int32
    end

    private def make(op_code : Bytecode, *operands : Int32) Array(Bytes)
      definition = Funk::INSTRUCTIONS[op_code.value]

      instruction_length = 1
      definition.operands_length.each { |x| instruction_length += x }

      instruction = [op_code.of(Bytes)]

      offset = 1
      operands.each_with_index do |i, o|
        width = definition.operands_length[i]
        case width
        when 2
          IO::ByteFormat::BigEndian.encode(o.to_ui16, instruction[offset...-1])
        when 1
          instruction[offset] = o.of(Byte)
        end
        offset += width
      end

      return instruction
    end

    private def add_constant(obj : Funk::Objects::Object) : Int32
      constants << obj
      constanst.size - 1
    end

    private def load_symbol(symbol : Funk::Symbol) : Array(Bytes)
      case symbole.scope
      when Funk::SymbolTable::GLOBAL_SCOPE
        make(Bytecode::GLOAD, symbol.index)
      when Funk::SymbolTable::LOCAL_SCOPE
        make(Bytecode::LOAD, symbol.index)
      else
        raise Funk::Errors::CompiletimeError.new("Unknown scope or not implemented #{symbol.scope}")
      end
    end

    private def enter_scope
      scope = CompliationScope.new
      scopes << scope
      scope_index += 1

      table = Funk::SymbolTable.new
      table.outer = symbol_table

      @symbol_table = table
    end

    private def last_instruction_is?(op_code : Bytecode) : Bool
      return false if current_instructions.size == 0

      scopes[scope_index].last_instruction.op_code == op_code
    end

    private def curent_instructions : Array(Bytes)
      scopes[scope_index].instructions
    end

    private def emit(op : Bytecode, *operands : Int32) : Int32
      ins = make(op, *operands)
      pos = add_instruction(ins)

      set_last_instruction(op, pos)

      pos
    end

    private def add_instruction(ins : Array(Bytes)) : Int32
      pos_new_instruction = current_instructions.size
      update_instructions = current_instructions << ins

      scopes[scope_index].instructions = update_instructions
      pos_new_instruction
    end

    private def set_last_instruction(op : Bytecode, pos : Int32)
      previous = scopes[scope_index].last_instruction
      last = EmittedInstruction.new(op_code: op, position: pos)
      scopes[scope_index].previous_instruction = previous
      scopes[scope_index].last_instruction     = last
    end
  end
end