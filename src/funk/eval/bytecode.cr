require "./instruction.cr"

module Funk
  struct Bytecode
    NULL   = 0
    IADD   = 1
    ISUB   = 2
    IMUL   = 3
    ILT    = 4
    IEQ    = 5
    BR     = 6
    BRT    = 7
    BRF    = 8
    ICONST = 9
    LOAD   = 10
    GLOAD  = 11
    STORE  = 12
    GSTORE = 13
    PRINT  = 14
    POP    = 15
    CALL   = 16
    RET    = 17
    STRING = 18
    BOOL   = 19
    HALT   = 20

    INSTRUCTIONS = [
      Instruction.new("nil"), # null
      Instruction.new("iadd"), # index is the opcode
      Instruction.new("isub"),
      Instruction.new("imul"),
      Instruction.new("ilt"),
      Instruction.new("ieq"),
      Instruction.new("br", 1),
      Instruction.new("brt", 1),
      Instruction.new("brf", 1),
      Instruction.new("iconst", 1),
      Instruction.new("load", 1),
      Instruction.new("gload", 1),
      Instruction.new("store", 1),
      Instruction.new("gstore", 1),
      Instruction.new("print"),
      Instruction.new("pop"),
      Instruction.new("call", 1),
      Instruction.new("ret"),
      Instruction.new("string", 1),
      Instruction.new("bool", 1),
      Instruction.new("halt")
    ] of Instruction
  end
end
