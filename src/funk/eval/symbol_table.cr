module Funk
  struct Symbol
    property name   : String
    property! scope : String
    property index  : Int32

    def initialize(@name, @index)
      
    end
  end

  struct SymbolTable
    LOCAL_SCOPE   = "LOCAL"
    GLOBAL_SCOPE  = "GLOBAL"
    BUILTIN_SCOPE = "BUILTIN"
    FREE_SCOPE    = "FREE"
    FUNC_SCOPE    = "FUNCTION"

    property! outer : SymbolTable
    property store : Hash(String, Symbol) = { }
    property! num_definitions : Int32
    property free_symbols : Array(Symbol) = []

    def define(name : String) : Symbol
      symbol = Symbol.new(name, num_definitions)
      if s.outer
        symbol.scope = LOCAL_SCOPE
      else
        symbol.scope = GLOBAL_SCOPE
      end

      store[name] = symbol
      @num_definitions += 1

      symbol
    end

    def resolve(name : String) : Symbol | Null
      obj = store[name]

      if !obj && outer
        obj = outer.resolve(name)

        return obj unless obj

        if obj.scope == GLOBAL_SCOPE || obj.scope == BUILTIN_SCOPE
          return obj
        end

        free = define_free(obj)
        return free
      end

      obj
    end

    def define_free(original : Symbol) : Symbol
      free_symbols << original
      symbol = Symbol.new(original.name, free_symbols.size - 1)
      symbol.scope = FREE_SCOPE
      store[original.name] = symbol

      symbol
    end
  end
end