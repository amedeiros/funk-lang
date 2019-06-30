module Funk
  module Objects
    abstract struct Object
      macro infix(meth)
        def {{meth.id}}(other : Object) : Object
          if other.class != self.class
            raise Funk::Errors::RuntimeError.new("Expected #{self.class} on right hand found #{other.class} instead")

          {% if meth == "+" || meth == "-" || meth == "*" || meth == "/" %}
          elsif self.class == Funk::Objects::Int
            Funk::Objects::Int.new(self.as(Funk::Objects::Int).value {{meth.id}} other.as(Funk::Objects::Int).value)
          {% end %}
          {% if meth == "<" || meth == ">" || meth == "<=" || meth == ">=" %}
          elsif self.class == Funk::Objects::Int
            self.as(Funk::Objects::Int).value {{meth.id}} other.as(Funk::Objects::Int).value ? Funk::VM::TRUE : Funk::VM::FALSE
          elsif self.class == Funk::Objects::String
            self.as(Funk::Objects::String).value {{meth.id}} other.as(Funk::Objects::String).value ? Funk::VM::TRUE : Funk::VM::FALSE
          {% end %}
          else
            raise Funk::Errors::RuntimeError.new("Undefined method #{{{meth}}} for #{self.class}")
          end
        end
      end

      infix "+"
      infix "-"
      infix "*"
      infix "<"
      infix ">"
      infix "<="
      infix ">="
      infix "=="
      infix "/"
    end
  end
end
