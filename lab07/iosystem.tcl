##########################################################################
#
# Filname: iosystem_template.tcl
# Author: Travis Reynertson
#
# This .tcl script will apply stimulus to the top-level pins of the FPGA
# 
#
##########################################################################


# Start the simulation over
restart

# Run circuit with no input stimulus settings
run 20 ns

# Set the clock to oscillate with a period of 10 ns
add_force clk {0} {1 5} -repeat_every 10
# Run the circuit for a bit
run 40 ns

# set the top-level inputs
add_force btnc 0
add_force btnl 0
add_force btnr 0
add_force btnu 0
add_force btnd 0
add_force sw 0
add_force RsTx 1
run 7 us

# Add your test stimulus here
# Run for 1 clock cycle
run 10 ns

# Changing the value of the switches to observe the impact on the LEDs and run for 2 clock cycles
add_force sw 1234 -radix hex
run 20 ns

# Change sw values again
add_force sw 4321 -radix hex

# Run for two clock cylces
run 20 ns

# Setting BTNR to high and running for two clock cycles
add_force btnr 1
run 20 ns

# Turn btnr low
add_force btnr 0

# Setting BTNL high and running for two clock cycles
add_force btnl 1
run 20 ns

# Turn btnl low
add_force btnl 0

# Setting BTNU high and running for two clock cycles
add_force btnu 1
run 20 ns

# Turn btnu low
add_force btnu 0

# Setting BTND high and running for two clock cycles
add_force btnd 1
run 20 ns

# Turn btnd low
add_force btnd 0

# Run for more than 1ms to see what happens to the timer value
run 2 ms

# Setting BTNC high and running for two clock cycles
add_force btnc 1
run 20 ns