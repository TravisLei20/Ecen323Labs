# restart the simulation at time 0
restart

# Run circuit with no input stimulus settings
run 20 ns

# Set the clock to oscillate with a period of 10 ns
add_force clk {0} {1 5} -repeat_every 10

# Run the circuit for two clock cycles
run 20 ns

# Set switches and btns to zero
add_force btnl 0
add_force btnc 0
add_force btnu 0
add_force btnd 0
add_force sw 0

# Run the circuit for two clock cycles
run 20 ns

# Reset system
add_force btnu 1

# Run the circuit for two clock cycles
run 20 ns

# Set btnu to zero
add_force btnu 0


# Set Write to register 1
add_force sw 0400 -radix hex
add_force btnl 1

# Run the circuit for five clock cycles
run 50 ns

# set btnl to zero
add_force btnl 0

# Run the circuit for two clock cycles
run 20 ns



# Write the value 0x00001234 to register 1
# add value to register
add_force sw 9234 -radix hex
add_force btnc 1

# Run the circuit for five clock cycles
run 50 ns

# set btnc to zero
add_force btnc 0

# Run the circuit for two clock cycles
run 20 ns



# Set Write to register 2
add_force sw 0800 -radix hex
add_force btnl 1

# Run the circuit for five clock cycles
run 50 ns

# set btnl to zero
add_force btnl 0

# Run the circuit for two clock cycles
run 20 ns



# Write the value 0x00003678 to register 2
# add value to register
add_force sw  b678 -radix hex
add_force btnc 1

# Run the circuit for five clock cycles
run 50 ns

# set btnc to zero
add_force btnc 0

# Run the circuit for two clock cycles
run 20 ns



# Perform an add operation between register 1 and register 2 
# and store the result in register 3

# Set Write to register 3 and read to register 1 and register 2
add_force sw 0c41 -radix hex
add_force btnl 1

# Run the circuit for five clock cycles
run 50 ns

# set btnc to zero
add_force btnl 0

# Run the circuit for two clock cycles
run 20 ns



# Perform add operation
add_force sw 0002 -radix hex
add_force btnc 1

# Run the circuit for five clock cycles
run 50 ns

# set btnc to zero
add_force btnc 0

# Run the circuit for two clock cycles
run 20 ns