# set op1=32'hf3212f37 and op2=32'h621c3ee7
add_force op1 f3212f37 -radix hex
add_force op2 621c3ee7 -radix hex

# set zero to 0
# add_force zero 0


# run for 100ns
run 100ns

############################################################
# set alu_op=4'b0000
add_force alu_op 0000

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b0001
add_force alu_op 0001

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b0010
add_force alu_op 0010

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b0011
add_force alu_op 0011

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b0110
add_force alu_op 0110

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b0111
add_force alu_op 0111

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b1000
add_force alu_op 1000

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b1001
add_force alu_op 1001

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b1010
add_force alu_op 1010

# run for 100ns
run 100ns

############################################################
# set alu_op=4'b1101
add_force alu_op 1101

# run for 100ns
run 100ns