require "../spec_helper"

describe Funk::Parser do
  describe "parse!" do
    it "should parse concatination" do
      left = "\"left\""
      right = "\"left\""
      parser = new_parser("#{left} +#{right}").parse!
      exp = parser.program.tree[0].as(Funk::ExpressionStatement).expression.as(Funk::InfixExpression)
      exp.left.token.type.should eq Funk::TokenType::String
      exp.left.token.raw.should  eq left
      exp.right.token.type.should eq Funk::TokenType::String
      exp.right.token.raw.should  eq right
    end

    it "should parse lambda expression" do
      expected_params = {"x", "y", "z"}
      code   = "-> (x, y, z) {\n x + y * z\n}"
      parser = new_parser(code).parse!
      exp    = parser.program.tree.first.as(Funk::ExpressionStatement)
      lambda = exp.expression.as(Funk::Lambda)
      params = lambda.parameters
      body   = lambda.body

      # Params check
      params.each_with_index do |param, index|
        ident = param.as(Funk::Identifier)
        expected_params[index].should eq ident.value
      end

      # Body check
      statement = body.statements.first.as(Funk::ExpressionStatement)
      body_exp  = statement.expression.as(Funk::InfixExpression)

      # Left
      body_exp.operator.should eq Funk::TokenType::Plus
      body_exp.left.as(Funk::Identifier).value.should eq "x"

      # Right another infix
      right_exp = body_exp.right.as(Funk::InfixExpression)
      right_exp.operator.should eq Funk::TokenType::Multiply
      right_exp.left.as(Funk::Identifier).value.should eq "y"
      right_exp.right.as(Funk::Identifier).value.should eq "z"
    end

    it "should parse a def lambda expression" do
      expected_params = {"x", "y", "z"}
      code   = "def my_func = -> (x, y, z) {\n x + y * z\n}"
      parser = new_parser(code).parse!
      exp    = parser.program.tree.first.as(Funk::DefStatement)
      lambda = exp.value.as(Funk::Lambda)
      name   = exp.name.as(Funk::Identifier)
      params = lambda.parameters
      body   = lambda.body

      # Func name
      name.value.should eq "my_func"

      # Lambda check

      # Params check
      params.each_with_index do |param, index|
        ident = param.as(Funk::Identifier)
        expected_params[index].should eq ident.value
      end

      # Body check
      statement = body.statements.first.as(Funk::ExpressionStatement)
      body_exp  = statement.expression.as(Funk::InfixExpression)

      # Left
      body_exp.operator.should eq Funk::TokenType::Plus
      body_exp.left.as(Funk::Identifier).value.should eq "x"

      # Right another infix
      right_exp = body_exp.right.as(Funk::InfixExpression)
      right_exp.operator.should eq Funk::TokenType::Multiply
      right_exp.left.as(Funk::Identifier).value.should eq "y"
      right_exp.right.as(Funk::Identifier).value.should eq "z"
    end

    it "should parse a while statement" do
      code = "while (x > 1) {\n x + 1\n}"
      parser = new_parser(code).parse!
      exp    = parser.program.tree.first.as(Funk::ExpressionStatement)
      while_stmt = exp.expression.as(Funk::WhileStatement)
      while_cond = while_stmt.cond.as(Funk::InfixExpression)

      while_cond.operator.should eq Funk::TokenType::GreaterThan
      while_cond.left.as(Funk::Identifier).value.should eq "x"
      while_cond.right.as(Funk::Numeric).value.should eq 1.0

      while_consequence = while_stmt.body.as(Funk::Block)
      while_stmt_body   = while_consequence.statements.first.as(Funk::ExpressionStatement)
      while_infix_body  = while_stmt_body.expression.as(Funk::InfixExpression)

      while_infix_body.operator.should eq Funk::TokenType::Plus
      while_infix_body.left.as(Funk::Identifier).value.should eq "x"
      while_infix_body.right.as(Funk::Numeric).value.should eq 1.0
    end

    it "should parse an if statement" do
      code   = "if (x > 1) {\n x + 1 \n}"
      parser = new_parser(code).parse!
      exp    = parser.program.tree.first.as(Funk::ExpressionStatement)
      if_exp = exp.expression.as(Funk::IfExpression)

      if_exp.alternative.is_a?(Funk::Null).should be_true
      if_cond = if_exp.cond.as(Funk::InfixExpression)

      if_cond.operator.should eq Funk::TokenType::GreaterThan
      if_cond.left.as(Funk::Identifier).value.should eq "x"
      if_cond.right.as(Funk::Numeric).value.should eq 1.0

      if_consequence = if_exp.consequence.as(Funk::Block)
      if_exp_body    = if_consequence.statements.first.as(Funk::ExpressionStatement)
      if_infix_body  = if_exp_body.expression.as(Funk::InfixExpression)

      if_infix_body.operator.should eq Funk::TokenType::Plus
      if_infix_body.left.as(Funk::Identifier).value.should eq "x"
      if_infix_body.right.as(Funk::Numeric).value.should eq 1.0
    end

    it "should parse an if/else statement" do
      code   = "if (x > 1) {\n x + 1 \n} else { x - 1 }"
      parser = new_parser(code).parse!
      exp    = parser.program.tree.first.as(Funk::ExpressionStatement)
      if_exp = exp.expression.as(Funk::IfExpression)

      # IF
      if_cond = if_exp.cond.as(Funk::InfixExpression)
      if_cond.operator.should eq Funk::TokenType::GreaterThan
      if_cond.left.as(Funk::Identifier).value.should eq "x"
      if_cond.right.as(Funk::Numeric).value.should eq 1.0

      if_consequence = if_exp.consequence.as(Funk::Block)
      if_exp_body    = if_consequence.statements.first.as(Funk::ExpressionStatement)
      if_infix_body  = if_exp_body.expression.as(Funk::InfixExpression)

      if_infix_body.operator.should eq Funk::TokenType::Plus
      if_infix_body.left.as(Funk::Identifier).value.should eq "x"
      if_infix_body.right.as(Funk::Numeric).value.should eq 1.0

      # ELSE
      if_exp.alternative.is_a?(Funk::IfExpression).should be_true
      else_exp = if_exp.alternative.as(Funk::IfExpression)
      else_exp.alternative.is_a?(Funk::Null).should be_true

      else_consequence  = else_exp.consequence.as(Funk::Block)
      else_exp_body     = else_consequence.statements.first.as(Funk::ExpressionStatement)
      else_infix_body   = else_exp_body.expression.as(Funk::InfixExpression)

      else_infix_body.operator.should eq Funk::TokenType::Minus
      else_infix_body.left.as(Funk::Identifier).value.should eq "x"
      else_infix_body.right.as(Funk::Numeric).value.should eq 1.0
    end

    it "should parse an if/elsif/else statement" do
      code   = "if (x > 1) {\n x + 1 \n} elsif(x < 1) {\n x + 2 \n} else {\n x - 1 \n}"
      parser = new_parser(code).parse!
      exp    = parser.program.tree.first.as(Funk::ExpressionStatement)
      if_exp = exp.expression.as(Funk::IfExpression)

      # IF
      if_cond = if_exp.cond.as(Funk::InfixExpression)
      if_cond.operator.should eq Funk::TokenType::GreaterThan
      if_cond.left.as(Funk::Identifier).value.should eq "x"
      if_cond.right.as(Funk::Numeric).value.should eq 1.0

      if_consequence = if_exp.consequence.as(Funk::Block)
      if_exp_body    = if_consequence.statements.first.as(Funk::ExpressionStatement)
      if_infix_body  = if_exp_body.expression.as(Funk::InfixExpression)

      if_infix_body.operator.should eq Funk::TokenType::Plus
      if_infix_body.left.as(Funk::Identifier).value.should eq "x"
      if_infix_body.right.as(Funk::Numeric).value.should eq 1.0

      # ELSE IF
      if_exp.alternative.is_a?(Funk::IfExpression).should be_true
      elsif_exp = if_exp.alternative.as(Funk::IfExpression)
      elsif_cond = elsif_exp.cond.as(Funk::InfixExpression)
      elsif_cond.operator.should eq Funk::TokenType::LessThan
      elsif_cond.left.as(Funk::Identifier).value.should eq "x"
      elsif_cond.right.as(Funk::Numeric).value.should eq 1.0

      elsif_consequence = elsif_exp.consequence.as(Funk::Block)
      elsif_exp_body = elsif_consequence.statements.first.as(Funk::ExpressionStatement)
      elsif_infix_body  = elsif_exp_body.expression.as(Funk::InfixExpression)

      elsif_infix_body.operator.should eq Funk::TokenType::Plus
      elsif_infix_body.left.as(Funk::Identifier).value.should eq "x"
      elsif_infix_body.right.as(Funk::Numeric).value.should eq 2.0

      # ELSE
      elsif_exp.alternative.is_a?(Funk::IfExpression).should be_true
      else_exp = elsif_exp.alternative.as(Funk::IfExpression)
      else_exp.alternative.is_a?(Funk::Null).should be_true

      else_consequence  = else_exp.consequence.as(Funk::Block)
      else_exp_body     = else_consequence.statements.first.as(Funk::ExpressionStatement)
      else_infix_body   = else_exp_body.expression.as(Funk::InfixExpression)

      else_infix_body.operator.should eq Funk::TokenType::Minus
      else_infix_body.left.as(Funk::Identifier).value.should eq "x"
      else_infix_body.right.as(Funk::Numeric).value.should eq 1.0
    end

    it "should parse a func call" do
      expected_args = {"x", "y"}
      code   = "my_func(x, y)"
      parser = new_parser(code).parse!
      
      exp       = parser.program.tree.first.as(Funk::ExpressionStatement)
      call_exp  = exp.expression.as(Funk::CallExpression)
      func_name = call_exp.name.as(Funk::Identifier)
      func_args = call_exp.arguments

      func_name.value.should eq "my_func"
      func_args.each_with_index do |arg, index|
        arg.as(Funk::Identifier).value.should eq expected_args[index]
      end
    end

    it "should parse multiple lines" do
      exp = "def add_one = -> (x) { return x + 1 }
      
def result  = display(add_one(add_one(1)))
      "

      parser = new_parser(exp).parse!
    end

    it "should parse a number" do
      parser = new_parser("100").parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Numeric
    end

    it "should parse a negative number" do
      parser = new_parser("-100").parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Numeric
    end

    it "should parse booleans" do
      {"#T", "#f"}.each do |bool|
        parser = new_parser(bool).parse!

        exp = parser.program.tree[0].as(Funk::ExpressionStatement)
        exp.token.type.should eq Funk::TokenType::Boolean
        exp.expression.as(Funk::Boolean).value.should eq (bool == "#T")
      end
    end

    it "should parse a identifier" do
      parser = new_parser("ident").parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Identifier
    end

    it "should parse def statements with different infix operators" do
      {"=", "+=", "-=", "/=", "*=", "**="}.each do |infix_op|
        parser = new_parser("def a #{infix_op} 1").parse!
        exp = parser.program.tree[0].as(Funk::DefStatement)

        exp.name.token.type.should eq Funk::TokenType::Identifier
        exp.name.value.should eq "a" 

        num = exp.value.as(Funk::Numeric)
        num.token.type.should eq Funk::TokenType::Numeric
        num.value.should eq 1
      end
    end

    it "should parse a string" do
      val    = "\"string\""
      parser = new_parser(val).parse!

      exp = parser.program.tree[0].as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::String
      exp.expression.as(Funk::StringNode).value.should eq val
    end

    it "should parse a null literal" do
      val    = "null"
      parser = new_parser(val).parse!

      exp = parser.program.tree.first.as(Funk::ExpressionStatement)
      exp.token.type.should eq Funk::TokenType::Null
      exp.expression.is_a?(Funk::Null).should be_true
    end

    # syntax errors

    it "should raise an error for a number followed by a unexpected token" do
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 2").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 #t").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 ident").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 \"string\"").parse! }
    end

    it "should raise an error for a string followed by a unexpected token" do
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" \"another\"").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" #t").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" ident").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("\"string\" 1").parse! }
    end

    it "should raise an error for a boolean followed by a unexpected token" do
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t #F").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t 100").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t ident").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#t \"string\"").parse! }
    end

    it "should raise an error for a negative sign - not followed by a numeric" do
      ["-\"string\"", "-#t"].each do |x|
        expect_raises(Funk::Errors::SyntaxError) { new_parser("-#{x}").parse! }
      end
    end

    it "should raise concat errors" do
      string = "\"string\""
      expect_raises(Funk::Errors::SyntaxError) { new_parser("#{string} + 1").parse! }
      expect_raises(Funk::Errors::SyntaxError) { new_parser("1 + #{string}").parse! }
    end

    it "should raise an error for missing structure" do
      # Lambdas
      expect_raises(Funk::Errors::SyntaxError, /Expected \(/) { new_parser("-> x) { x + 1}").parse! }
      expect_raises(Funk::Errors::SyntaxError, /Expected \)/) { new_parser("-> (x { x + 1}").parse! }
      expect_raises(Funk::Errors::SyntaxError, /Expected \{/) { new_parser("-> (x)  x + 1}").parse! }
      expect_raises(Funk::Errors::SyntaxError, /Expected \}/) { new_parser("-> (x) { x + 1").parse! }

      # If expressions
      expect_raises(Funk::Errors::SyntaxError, /Expected \(/) { new_parser("if x > 1) { x + 1 }").parse! }
      expect_raises(Funk::Errors::SyntaxError, /Expected \)/) { new_parser("if (x > 1 { x + 1 }").parse! }
      expect_raises(Funk::Errors::SyntaxError, /Expected \{/) { new_parser("if (x > 1)  x + 1 }").parse! }
      expect_raises(Funk::Errors::SyntaxError, /Expected \}/) { new_parser("if (x > 1) { x + 1 ").parse! }
    end

    it "should raise an error for an infix assignment with a lambda other than =" do
      {"+=", "-=", "/=", "*=", "**="}.each do |infix_op|
        expect_raises(Funk::Errors::SyntaxError) do
          new_parser("def #{infix_op} -> (x) { return x + 1 }").parse!
        end
      end
    end
  end
end
