#######################
#
# fib_template.asm
#
# Put Your name here
#
# Template for completing Fibinnoci sequence in lab 11
#
# Version 1.2
#
# Memory Organization:
#   0x0000-0x1fff : text
#   0x2000-0x3fff : data
# Registers:
#   x0: Zero
#   x1: return address
#   x2 (sp): stack pointer (starts at 0x3ffc)
#   x3 (gp): global pointer (to data: 0x2000)
#   s0: Loop index for Fibonacci call
#   s1: Pointer to 'fib_count' in data segment
#   x10-x11: function arguments/return values
#
#######################
.globl  main

.text
main:

	#########################
	# Program Initialization
	#########################

	# Setup the stack: sp = 0x3ffc
	lui sp, 4				# 4 << 12 = 0x4000
	addi sp, sp, -4			# 0x4000 - 4 = 0x3ffc
	# setup the global pointer to the data segment (2<<12 = 0x2000)
	lui gp, 2
	
	# Prepare the loop to iterate over each Fibonacci call
	addi s0, x0, 0			# Loop index (initialize to zero)

	# Load the loop terminal count value (in the .data segment)

	# The following assembly language macro is useful for accessing variables
	# in the data segment. This macro helps determine the address of data variables.
	# The form of the macro is '%lo(label)(register). The 'label' refers to
	# a label in the data segment and the register refers to the RISC-V base
	# register used to access the memory. In this case, the label is 
	# 'fib_count' (see the .data segment) and the register is 'gp' which points
	# to the data segment. The assembler will figure out what the offset is for
	# 'fib_count' from the data segment.
	lw s1,%lo(fib_count)(gp)	 # Load terminal count into s1

FIB_LOOP:
	# Set up argument for call to iterative fibinnoci
	mv a0, s0
	jal iterative_fibinnoci
	# Save the result into s2
	mv s2, a0
	# Set up argument for call to recursive fibinnoci
	mv a0, s0	
	jal recursive_fibinnoci
	# Save the result into t3
	mv s3, a0
	
	# Determine index in circular buffer on where to store result
	andi s4, s0, 0xf	# keep lower 4 bits (between zero and fifteen)
	# multiply by 4 (shift left by 2) to get offset
	slli s4, s4, 2
	
	# Compute base pointer to iterative_data
	addi s5, x3, %lo(iterative_data)
	# add the offset into the table based on the current index
	add s5, s5, s4
	# Store result
	sw s2,(s5)
	
	# Compute base pointer to recursive_data
	addi s5, x3, %lo(recursive_data)
	add s5, s5, s4
	# Store result
	sw s3,(s5)
	
	# Increment pointer and see if we are done
	beq s0, s1, done
	addi s0, s0, 1
	# Not done, jump back to do another iteration
	j FIB_LOOP

done:
	
	# Now add the results and place in a0
	addi t0, x0, 0     	# Counter (initialize to zero)
	addi t1, x0, 16		# Terminal count for loop
	addi a0, x0, 0		# Intialize a0 t0 zero
	# create a pointer to the iterative data
	addi t2, gp, %lo(iterative_data)
	# create a pointer to the recursive data
	addi t3, gp, %lo(recursive_data)
	
	# Add the results of all the calls
final_add:
	lw t4, (t2)
	add a0, a0, t4
	lw t4, (t3)
	add a0, a0, t4
	addi t2, t2, 4		# increment pointer
	addi t3, t3, 4		# increment pointer
	addi t0, t0, 1
	blt t0, t1, final_add
	
	# Done here!
END:
	addi a7, x0, 10   # Exit system call
	ecall
	jal x0, END
	# Should never get here


iterative_fibinnoci:

	# This is where you should create your iterative Fibinnoci function.
	# The input argument arrives in a0. You should create a new stack frame
	# and put your resul in a0 when you return.
	
	
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

recursive_fibinnoci:

	# This is where you should create your iterative Fibinnoci function.
	# The input argument arrives in a0. You should create a new stack frame
	# and put your resul in a0 when you return.
fibinnoci:	
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
	beq s0, zero, return_recursive	# If the input is equal to zero then return zero
	
	# The second if statement
	addi t0, x0, 1		# Setting t0 to one
	beq s0, t0, return_recursive	# If the input is equal to one then return one
	
	
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
	
	beq x0, x0, return_recursive	# Calls return
	
	
return_recursive:	lw s0, 0(sp)		# Restore callee address
	lw s1, 4(sp)		# Restore callee address
	lw s2, 8(sp)		# Restore callee address
	lw s3, 12(sp)		# Restore callee address
	lw s4, 16(sp)		# Restore callee address
	lw ra, 20(sp)		# Restore return address
	addi sp, sp, 24		# Restore sp to its origional address
		
	ret
	# Extra NOPs inserted to make sure we have instructions in the pipeline
	nop
	nop
	nop

.data

# Indicates how many Fibonacci sequences to compute
fib_count:
	.word 15   # Perform Fibonacci sequence from 0 to 15
# Reserve 16 words for results of iterative sequences
# (16 words of 4 bytes each for a total of 64 bytes)
iterative_data:
	.space 64 
# Reserve 16 words for results of recursive sequences
# (16 words of 4 bytes each for a total of 64 bytes)
recursive_data:
	.space 64 

