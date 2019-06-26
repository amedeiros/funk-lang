require "./funk/*"
require "./funk/syntax/*"
require "./funk/eval/*"

module Funk
end

# hello = [Funk::Bytecode::ICONST, 1,
# 		Funk::Bytecode::ICONST, 2,
# 		Funk::Bytecode::IADD,
# 		Funk::Bytecode::PRINT,
#     Funk::Bytecode::HALT]
    
# func_metadata = [Funk::FunctionMeta.new("main", 0, 0, 0)]
# vm = Funk::VM.new(hello, Array(Int32).new, func_metadata)
# vm.trace = true
# vm.exec(func_metadata[0].address)

# FACTORIAL_INDEX = 1
# FACTORIAL_ADDRESS = 0
# MAIN_ADDRESS = 21

# factorial = [
# #.def factorial: ARGS=1, LOCALS=0	ADDRESS
# #	IF N < 2 RETURN 1
# 			Funk::Bytecode::LOAD, 0,				# 0
# 			Funk::Bytecode::ICONST, 2,			# 2
# 			Funk::Bytecode::ILT,						# 4
# 			Funk::Bytecode::BRF, 10,				# 5
# 			Funk::Bytecode::ICONST, 1,			# 7
# 			Funk::Bytecode::RET,						# 9
# #CONT:
# #	RETURN N * FACT(N-1)
# 			Funk::Bytecode::LOAD, 0,				# 10
# 			Funk::Bytecode::LOAD, 0,				# 12
# 			Funk::Bytecode::ICONST, 1,			# 14
# 			Funk::Bytecode::ISUB,						# 16
# 			Funk::Bytecode::CALL, FACTORIAL_INDEX,	# 17
# 			Funk::Bytecode::IMUL,					# 19
# 			Funk::Bytecode::RET,					# 20
# #.DEF MAIN: ARGS=0, LOCALS=0
# # PRINT FACT(1)
# 			Funk::Bytecode::ICONST, 5,				# 21    <-- MAIN METHOD!
# 			Funk::Bytecode::CALL, FACTORIAL_INDEX,	# 23
# 			Funk::Bytecode::PRINT,				# 25
# 			Funk::Bytecode::HALT					# 26
# ]
# factorial_metadata = [
# 		#.def factorial: ARGS=1, LOCALS=0	ADDRESS
# 		Funk::FunctionMeta.new("main", 0, 0, MAIN_ADDRESS),
# 		Funk::FunctionMeta.new("factorial", 1, 0, FACTORIAL_ADDRESS)
# ]


# vm = Funk::VM.new(factorial, Array(Int32).new, factorial_metadata)
# vm.trace = true
# vm.exec(factorial_metadata[0].address)

f = [
	#								ADDRESS
	#.def main() { print f(10); }
		Funk::Bytecode::ICONST, 10,					# 0
		Funk::Bytecode::CALL, 1,					# 2
		Funk::Bytecode::PRINT,						# 4
		Funk::Bytecode::HALT,						# 5
	#.def f(x): ARGS=1, LOCALS=1
	#  a = x;
    Funk::Bytecode::LOAD, 0,					# 6	<-- start of f
    Funk::Bytecode::STORE, 1,
	# return 2*a
    Funk::Bytecode::LOAD, 1,
    Funk::Bytecode::ICONST, 2,
    Funk::Bytecode::IMUL,
    Funk::Bytecode::RET
]

f_metadata = [
  Funk::FunctionMeta.new("main", 0, 0, 0),
  Funk::FunctionMeta.new("f", 1, 1, 6)
]
vm = Funk::VM.new(f, Array(Int32).new, f_metadata)
vm.trace = true
vm.exec(f_metadata[0].address)