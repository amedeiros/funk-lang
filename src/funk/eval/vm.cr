require "./bytecode"
require "./context"
require "../syntax/errors"

module Funk
  class VM
    DEFAULT_STACK_SIZE      = 1_000
    DEFAULT_CALL_STACK_SIZE = 1_000
    FALSE = 0
    TRUE  = 1

    # Registers
    property ip = 0  # Instruction Pointer
    property sp = -1 # Stack Pointer

    # Memory
    property code    = Array(Int32).new
    property globals = Array(Int32).new
    property stack   = Array(Int32).new(DEFAULT_STACK_SIZE)
    property! ctx : Context

    property metadata : Array(FunctionMeta)
    property trace : Bool

    def initialize(@code, @globals, @metadata, @trace = false)
    end

    def exec(start_ip : Int32)
      @ip  = start_ip
      @ctx = Context.new(nil, 0, metadata[0]) # simulate a call to main()
      cpu
    end

    protected def cpu
      opcode = code[ip]
      a = 0
      b = 0
      addr = 0
      regnum = 0

      while (opcode != Bytecode::HALT && ip < code.size)
        printf("%-35s", dis_instr()) if trace
        @ip += 1

        case opcode
        when Bytecode::IADD
          b = stack[postfix_decrement_sp]
          a = stack[postfix_decrement_sp]
          @stack[prefix_increment_sp] = a + b
        when Bytecode::ISUB
          b = stack[postfix_decrement_sp]
          a = stack[postfix_decrement_sp]
          @stack[prefix_increment_sp] = a - b
        when Bytecode::IMUL
          b = stack[postfix_decrement_sp]
          a = stack[postfix_decrement_sp]
          @stack[prefix_increment_sp] = a * b
        when Bytecode::ILT
          b = stack[postfix_decrement_sp]
          a = stack[postfix_decrement_sp]
          @stack[prefix_increment_sp] = (a < b) ? TRUE : FALSE
        when Bytecode::IEQ
          b = stack[postfix_decrement_sp]
          a = stack[postfix_decrement_sp]
          @stack[prefix_increment_sp] = (a == b) ? TRUE : FALSE
        when Bytecode::BR
          @ip = code[postfix_increment_ip]
        when Bytecode::BRT
          addr = code[postfix_increment_ip]
          @ip = addr if stack[postfix_decrement_sp] == TRUE
        when Bytecode::BRF
          addr = code[postfix_increment_ip]
					@ip = addr if stack[postfix_decrement_sp] == FALSE 
        when Bytecode::ICONST
          stack.insert(prefix_increment_sp, code[postfix_increment_ip])
        when Bytecode::LOAD
          regnum = code[postfix_increment_ip]
          @stack[prefix_increment_sp] = ctx.locals[regnum]
        when Bytecode::GLOAD
          addr = code[postfix_increment_ip]
					stack[prefix_increment_sp] = globals[addr]
        when Bytecode::STORE
          regnum = code[postfix_increment_ip]
					ctx.locals[regnum] = stack[postfix_decrement_sp]
        when Bytecode::GSTORE
          addr = code[postfix_increment_ip]
					globals[addr] = stack[postfix_decrement_sp]
        when Bytecode::PRINT
          puts stack[postfix_decrement_sp]
        when Bytecode::POP
          prefix_decrement_sp
        when Bytecode::CALL
          # expects all args on stack
					findex = code[postfix_increment_ip]			# index of target function
					nargs  = metadata[findex].nargs	# how many args got pushed
					@ctx   = Funk::Context.new(ctx, ip, metadata[findex])
					# copy args into new context
          firstarg = sp - nargs + 1
          
          i = 0
          while i < nargs
            ctx.locals.insert(i, stack[firstarg + i])
            i += 1
          end
          
					@sp -= nargs
					@ip = metadata[findex].address		# jump to function
        when Bytecode::RET
          @ip  = ctx.return_ip
					@ctx = ctx.invoking_context			# pop
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
