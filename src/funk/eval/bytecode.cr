require "./instruction.cr"

module Funk
  struct Bytecode
    NULL   = 0
    IADD   = 1
    ISUB   = 2
    IMUL   = 3
    IDIV   = 4
    ILT    = 5
    IGT    = 6
    IEQ    = 7
    IGTEQ  = 8
    ILTEQ  = 9
    BR     = 10
    BRT    = 11
    BRF    = 12
    ICONST = 13
    LOAD   = 14
    GLOAD  = 15
    STORE  = 16
    GSTORE = 17
    PRINT  = 18
    POP    = 19
    CALL   = 20
    RET    = 21
    STRING = 22
    BOOL   = 23
    HALT   = 24

    INSTRUCTIONS = [
      Instruction.new("nil"), # null
      Instruction.new("iadd"), # index is the opcode
      Instruction.new("isub"),
      Instruction.new("imul"),
      Instruction.new("idiv"),
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
