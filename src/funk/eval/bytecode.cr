require "./instruction.cr"

module Funk
  enum Bytecode
    NULL
    ADD
    SUB
    MUL
    DIV
    LT
    GT
    EQ
    GTEQ
    LTEQ
    CONSTANT
    LOAD
    STORE
    GLOAD
    GSTORE
    PRINT
    POP
    CALL
    RET
    TRUE
    FALSE
    HALT
  end

  INSTRUCTIONS = [
    Instruction.new("nil"), # null
    Instruction.new("OpAdd"), # index is the opcode
    Instruction.new("OpSub"),
    Instruction.new("OpMul"),
    Instruction.new("OpDiv"),
    Instruction.new("OpLessThan"),
    Instruction.new("OpGreatherThan"),
    Instruction.new("OpEqual"),
    Instruction.new("OpGreaterThanEqual"),
    Instruction.new("OpLessThanEqual"),
    Instruction.new("OpConst", [2]),
    Instruction.new("OpLoad", [1]),
    Instruction.new("OpStore", [1]),
    Instruction.new("OpGlobalLoad", [2]),
    Instruction.new("OpGlobalStore", [2]),
    Instruction.new("print"),
    Instruction.new("pop"),
    Instruction.new("call", [1]),
    Instruction.new("OpReturn"),
    Instruction.new("OpTrue"),
    Instruction.new("OpFalse")
    Instruction.new("halt")
  ] of Instruction
end
