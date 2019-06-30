require "./instruction.cr"

module Funk
  struct Bytecode
    NULL   = 0
    IADD   = 1
    ISUB   = 2
    IMUL   = 3
    ILT    = 4
    IGT    = 5
    IEQ    = 6
    IGTEQ  = 7
    ILTEQ  = 8
    BR     = 9
    BRT    = 10
    BRF    = 11
    ICONST = 12
    LOAD   = 13
    GLOAD  = 14
    STORE  = 15
    GSTORE = 16
    PRINT  = 17
    POP    = 18
    CALL   = 19
    RET    = 20
    STRING = 21
    BOOL   = 22
    HALT   = 23

    INSTRUCTIONS = [
      Instruction.new("nil"), # null
      Instruction.new("iadd"), # index is the opcode
      Instruction.new("isub"),
      Instruction.new("imul"),
      Instruction.new("ilt"),
      Instruction.new("igt"),
      Instruction.new("ieq"),
      Instruction.new("igteq"),
      Instruction.new("ilteq"),
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
