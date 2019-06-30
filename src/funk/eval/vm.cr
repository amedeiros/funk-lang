require "./bytecode"
require "./context"
require "../syntax/errors"
require "../objects/*"

module Funk
  class VM
    DEFAULT_STACK_SIZE      = 1_000
    DEFAULT_CALL_STACK_SIZE = 1_000
    FALSE = Funk::Objects::Boolean.new(false)
    TRUE  = Funk::Objects::Boolean.new(true)
    NULL  = Funk::Objects::Null.new

    # Registers
    property ip = 0  # Instruction Pointer
    property sp = -1 # Stack Pointer

    property code    = Array(Int32).new
    property globals = Array(Funk::Objects::Object).new
    property string_table = Array(Funk::Objects::String).new
    property! stack : Array(Funk::Objects::Object)
    property! ctx   : Context

    property metadata = [] of Funk::Objects::Closure
    property trace : Bool

    def initialize(code, @globals, metadata, @trace = false)
    end

    def initialize(@trace)
    end

    def exec(start_ip : Int32)
      @metadata << Funk::Objects::Closure.new(Funk::Objects::CompiledFunction.new(code), "main")
      @stack = Array(Funk::Objects::Object).new(DEFAULT_STACK_SIZE)
      @sp    = -1
      @ip    = start_ip
      @ctx   = Context.new(@ctx, 0, metadata.last)
      cpu
    end

    def last_popped_stack : Funk::Objects::Object | Nil
      return nil if sp >= stack.size || stack.size == 0

      stack[sp]
    end

    protected def cpu
      opcode = code[ip]
      a      = 0
      b      = 0
      addr   = 0
      regnum = 0

      while (opcode != Bytecode::HALT && ip < code.size)
        printf("%-35s", dis_instr()) if trace
        @ip += 1

        case opcode
        when Bytecode::NULL
          stack.insert(prefix_increment_sp, NULL)
        when Bytecode::IADD
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a + b)
        when Bytecode::ISUB
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a - b)
        when Bytecode::IMUL
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a * b)
        when Bytecode::ILT
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a < b)
        when Bytecode::IGT
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a > b)
        when Bytecode::IEQ
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a == b)
        when Bytecode::IGTEQ
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a >= b)
        when Bytecode::ILTEQ
          b = stack.pop
          a = stack.pop
          stack.insert(prefix_decrement_sp, a <= b)
        when Bytecode::STRING
          stack.insert(prefix_increment_sp, string_table[code[postfix_increment_ip]])
        when Bytecode::BR
          @ip = code[postfix_increment_ip]
        when Bytecode::BRT
          addr = code[postfix_increment_ip]
          @ip = addr if stack[postfix_decrement_sp] == TRUE
        when Bytecode::BRF
          addr = code[postfix_increment_ip]
					@ip = addr if stack[postfix_decrement_sp] == FALSE 
        when Bytecode::ICONST
          stack.insert(prefix_increment_sp, Funk::Objects::Int.new(code[postfix_increment_ip].to_i64))
        when Bytecode::BOOL
          stack.insert(prefix_increment_sp, code[postfix_increment_ip] == 0 ? FALSE : TRUE)
        when Bytecode::LOAD
          regnum = code[postfix_increment_ip]
          stack[prefix_increment_sp] = ctx.locals[regnum]
        when Bytecode::GLOAD
          addr = code[postfix_increment_ip]
					stack[prefix_increment_sp] = globals[addr]
        when Bytecode::STORE
          regnum = code[postfix_increment_ip]
          ctx.locals.insert(regnum, stack[postfix_decrement_sp])
        when Bytecode::GSTORE
          addr = code[postfix_increment_ip]
					globals[addr] = stack[postfix_decrement_sp]
        when Bytecode::PRINT
          postfix_decrement_sp
          puts stack.shift
        when Bytecode::POP
          prefix_decrement_sp
        when Bytecode::CALL
          # expects all args on stack
          findex = code[postfix_increment_ip]			# index of target function
          func   = metadata[findex]
          nargs  = func.compiled_function.nargs	# how many args got pushed
          @ctx   = Funk::Context.new(ctx, ip, func, @code)
          
					# copy args into new context
          firstarg = sp - nargs + 1
          
          i = 0
          while i < nargs
            ctx.locals.insert(i, stack[firstarg + i])
            i += 1
          end
          
					@sp  -= nargs
          @ip   = 0
          @code = func.compiled_function.code
        when Bytecode::RET
          @ip   = ctx.return_ip
          @code = ctx.return_code
          @ctx  = ctx.invoking_context			# pop

          if @code.size == 0
            @ip = 0
            @code << Funk::Bytecode::HALT
          end
        when Bytecode::HALT
          exit
        else
          raise Funk::Errors::RuntimeError.new("Invalid opcode #{opcode} at #{ip - 1}")
        end

        printf("%-22s %s\n", stackString, call_stack_string) if trace

        opcode = code[ip]
      end

      if trace
        printf("%-35s", dis_instr)
        puts stackString
        dump_data_memory
      end
    end

    protected def stackString : String
      String.build do |io|
        io << "stack=["
        i = 0

        while (i <= sp)
          io << " "
          io << stack[i]
          i += 1
        end
        
        io << " ]"
      end
    end

    protected def call_stack_string : String
      stack  = Array(String).new
      c      = ctx
      
      while c != nil
        stack.insert(0, c.metadata.name) if c && c.metadata
        c = c.invoking_context if c
      end
      
      "calls=#{stack.to_s}"
    end

    protected def dump_data_memory : Void
      puts "Data memory:"
      addr = 0
      
      globals.each do |o|
        printf("%04d: %s\n", addr, o)
        addr += 1
      end
      
      puts
    end

    protected def dis_instr : String
      opcode  = code[ip]
      op_name = Bytecode::INSTRUCTIONS[opcode].name
      
      String.build do |io|
        io << sprintf("%04d:\t%-11s", ip, op_name)
        nargs = Bytecode::INSTRUCTIONS[opcode].nargs

        if opcode == Bytecode::CALL
          io << metadata[code[ip + 1]].name
        elsif nargs > 0
          operands = Array(String).new
          i = ip + 1

          while i <= ip + nargs
            operands << code[i].to_s
            i += 1
          end

          i = 0

          while i < operands.size
            s = operands[i]
            io << ", " if i > 0
            io << s
            i += 1
          end
        end
      end
    end

    private def postfix_decrement_sp : Int32
      sp_copy = sp
      @sp -= 1
      sp_copy
    end

    private def prefix_decrement_sp : Int32
      @sp -= 1
      sp
    end

    private def prefix_increment_sp : Int32
      @sp += 1
      sp
    end

    private def postfix_increment_ip : Int32
      ip_copy = ip
      @ip += 1
      ip_copy
    end
  end
end
