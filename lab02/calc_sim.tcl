# restart the simulation at time 0
restart

# Run circuit with no input stimulus settings
run 20 ns

# Set the clock to oscillate with a period of 10 ns
add_force clk {0} {1 5} -repeat_every 10

# Run the circuit for two clock cycles
run 20 ns

# Issue global reset
add_force btnu 1

# Run the circuit for two clock cycles
run 20 ns

# Set btnu to 0
add_force btnu 0

# Run the circuit for two clock cycles
run 20 ns

# First Phase
# set btnl to 0, btnc to 1, btnr 1
add_force btnl 0
add_force btnc 1
add_force btnr 1

# Set sw to 0x1234
add_force sw 1234 -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns

# Second Phase
# set btnl to 0, btnc to 1, btnr 0
add_force btnl 0
add_force btnc 1
add_force btnr 0

# Set sw to 0x0ff0
add_force sw 0ff0 -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns

# Third Phase
# set btnl to 0, btnc to 0, btnr 0
add_force btnl 0
add_force btnc 0
add_force btnr 0

# Set sw to 0x324f
add_force sw 324f -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns

# Fourth Phase
# set btnl to 0, btnc to 0, btnr 1
add_force btnl 0
add_force btnc 0
add_force btnr 1

# Set sw to 0x2d31
add_force sw 2d31 -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns

# Fifth Phase
# set btnl to 1, btnc to 0, btnr 0
add_force btnl 1
add_force btnc 0
add_force btnr 0

# Set sw to 0xffff
add_force sw ffff -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns

# Sixth Phase
# set btnl to 1, btnc to 0, btnr 1
add_force btnl 1
add_force btnc 0
add_force btnr 1

# Set sw to 0x7346
add_force sw 7346 -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns

# Seventh Phase
# set btnl to 1, btnc to 0, btnr 1
add_force btnl 1
add_force btnc 0
add_force btnr 1

# Set sw to 0xffff
add_force sw ffff -radix hex

# Run the circuit for two clock cycles with btnd set to 1
add_force btnd 1
run 20 ns

# Set btnd to 0
add_force btnd 0

# Run the circuit for two clock cycles
run 20 ns