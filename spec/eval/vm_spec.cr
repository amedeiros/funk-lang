require "../spec_helper"

describe Funk::VM do
  describe "+" do
    it "should add two numbers" do
      code = compile("1 + 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 4
    end

    it "should add multiple numbers" do
      code = compile("1 + 3 + 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 7
    end
  end

  describe "-" do
    it "should subtract two numbers" do
      code = compile("7 - 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 4
    end

    it "should subtract multiple numbers" do
      code = compile("12 - 2 - 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 7
    end
  end

  describe "*" do
    it "should multiply two numbers" do
      code = compile("2 * 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 6
    end

    it "should multiply multiple numbers" do
      code = compile("2 * 3 * 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 18
    end
  end

  describe "/" do
    it "should multiply two numbers" do
      code = compile("2 * 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 6
    end

    it "should multiply multiple numbers" do
      code = compile("2 * 3 * 3")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 18
    end
  end

  describe "order of operations" do
    it "should follow order of operations" do
      code = compile("1 + 2 * 3 + 10")
      vm   = Funk::VM.new
      vm.code = code
      vm.exec(0)
      int = vm.last_popped_stack.as(Funk::Objects::Int)

      int.value.should eq 17
    end
  end

  describe "comparisions" do
    describe "==" do
      it "should be true for equal ints" do
        code = compile("2 == 2")
        vm   = Funk::VM.new
        vm.code = code
        vm.exec(0)
        bool = vm.last_popped_stack.as(Funk::Objects::Boolean)

        bool.value.should be_true
      end

      it "should be false for non-equal ints" do
        code = compile("2 == 1")
        vm   = Funk::VM.new
        vm.code = code
        vm.exec(0)
        bool = vm.last_popped_stack.as(Funk::Objects::Boolean)

        bool.value.should be_false
      end

      it "should be true for equal strings" do
        compiler = Funk::Compiler.new
        prog = new_parser("\"apples\" == \"apples\"").parse!.program
        code = compiler.visit_program(prog)
        vm   = Funk::VM.new
        vm.code = code
        vm.string_table = compiler.string_table
        vm.exec(0)
        bool = vm.last_popped_stack.as(Funk::Objects::Boolean)

        bool.value.should be_true
      end
    end
  end
end