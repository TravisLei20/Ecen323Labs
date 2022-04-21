#######################
# fib_iterative.s
# Name: Travis Reynertson
# Date: 1/26/2022
#
# Fibinnoci iterative function using RISC-V language in lab 4
#
#######################
.globl  main

.data
fib_input:
	.word 10
	
result_str:
	.string "\nFibinnoci Number is "

.text
main:

	# Load n into a0 as the argument
	lw a0, fib_input
	
	# Call the fibinnoci function
	jal fibinnoci
	
	# Save the result into s2
	mv s2, a0 

	# Print the Result string
	la a0,result_str      # Put string pointer in a0
        li a7,4               # System call code for print_str
        ecall                 # Make system call

        # Print the number        
 	mv a0, s2
        li a7,1               # System call code for print_int
        ecall                 # Make system call

	# Exit (93) with code 0
        li a0, 0
        li a7, 93
        ecall
        ebreak

fibinnoci:

	# This is where you should create your Fibinnoci function.
	# The input argument arrives in a0. You should put your result
	# in a0.
	#
	# You should properly manage the stack to save registers that
	# you use.
	
	addi sp, sp, -8		# This gives room to save values on the stack (approximately two variables)
	sw s0, 0(sp)		# This saves the callee
	sw ra, 4(sp)		# This is the return address being saved
	
	mv s0, a0		# This saves the input into s0
	
	# The first if statement
	beq s0, zero, return	# If the input is equal to zero then return zero
	
	# The second if statemetn
	addi t0, x0, 1		# Setting t0 to one
	beq s0, t0, return	# If the input is equal to one then return one
	
	addi t2, x0, 0		# Setting t2(fib_2) to 0
	addi t1, x0, 1		# Setting t1(fib_1) to 1
	addi t0, x0, 0		# Setting t0(fib) to 0
	
	addi t3, x0, 2		# Setting t3(i) to 2
	
	
loop:	blt s0, t3, return	# If a is less then i then return
	add t0, t1, t2		# Add t1(fib_1) to t2(fib_2) and store the value into t0(fob)
	mv t2, t1		# Set t2(fib_2) to t1(fib_1)'s values
	mv t1, t0		# Set t1(fib_1) to t0(fib)'s values
	addi t3, t3, 1		# Increment t3(i) by one (i++)
	mv a0, t0		# Sets the return value to t0(fib)
	beq x0, x0, loop	# Returns to the beginning of LOOP
	
return:	lw s0, 0(sp)		# Restore callee address
	lw ra, 4(sp)		# Restore return address
	addi sp, sp, 8		# Restore sp to its origional address
	

	ret
