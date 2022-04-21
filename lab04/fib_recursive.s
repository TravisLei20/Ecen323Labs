#######################
# fib_recursive.s
# Name: Travis Reynertson
# Date: 1/26/2022
#
# Fibinnoci recursive function using RISC-V language in lab 4
#
#######################
.globl  main

.data
fib_input:
	.word 5
	
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
	
	
	addi sp, sp, -24	# This gives room to save values on the stack (approximately five variables)
	sw s0, 0(sp)		# This saves the callee for s0
	sw s1, 4(sp)		# This saves the callee for s1
	sw s2, 8(sp)		# This save the callee for s2
	sw s3, 12(sp)		# This saves the callee for s3
	sw s4, 16(sp)		# This saves the callee for s4
	sw ra, 20(sp)		# This is the return address being saved
			
	
	mv s0, a0		# This saves the input into s0
	mv s1, a0		# This saves the input into s1
	
	# The first if statement
	beq s0, zero, return	# If the input is equal to zero then return zero
	
	# The second if statement
	addi t0, x0, 1		# Setting t0 to one
	beq s0, t0, return	# If the input is equal to one then return one
	
	
	addi s0, s0, -1		# This subtracts s0 by one (a-1)
	mv a0, s0		# This takes s0 and puts its values into a0
	jal fibinnoci		# Calls fibinnoci
	
	mv s2, a0		# Stores the value of a0 (the return value of the fibinnoci funtion that was just called) into s2
	
	addi s1, s1, -2		# This subtracts s1 by one (a-2)
	mv a0, s1		# This takes s1 and puts its values into a0
	jal fibinnoci		# Calls fibinnoci
	
	mv s3, a0		# Stores the value of a0 (the return value of the fibinnoci funtion that was just called) into s3
	
	add t0, s2, s3		# This adds the results of the two recursive fibinnoci values of s2 and s3 and stores it into t0
	
	add s4, s4, t0		# The result of t0 will be added to s4
	
	mv a0, s4		# The values of s4 are stored into a0
	
	beq x0, x0, return	# Calls return
	
	
return:	lw s0, 0(sp)		# Restore callee address
	lw s1, 4(sp)		# Restore callee address
	lw s2, 8(sp)		# Restore callee address
	lw s3, 12(sp)		# Restore callee address
	lw s4, 16(sp)		# Restore callee address
	lw ra, 20(sp)		# Restore return address
	addi sp, sp, 24		# Restore sp to its origional address
	
	ret
