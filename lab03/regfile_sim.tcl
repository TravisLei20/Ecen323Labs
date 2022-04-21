# restart the simulation at time 0
restart

# Run circuit with no input stimulus settings
run 20 ns

# Set the clock to oscillate with a period of 10 ns
add_force clk {0} {1 5} -repeat_every 10

# Run the circuit for two clock cycles
run 20 ns

#set write high
add_force write 1

# Run the circuit for one clock cycles
run 10 ns



# Set writeReg=00001
add_force writeReg 00001

# Set writeData=32'hffffffff
add_force writeData ffffffff -radix hex

# Run the circuit for two clock cycles
run 20 ns



# Set writeReg=00010
add_force writeReg 00010

# Set writeData=32'hfff00fff
add_force writeData fff00fff -radix hex

# Run the circuit for two clock cycles
run 20 ns


# Set writeReg=00011
add_force writeReg 00011

# Set writeData=32'h00ffff00
add_force writeData 00ffff00 -radix hex

# Run the circuit for two clock cycles
run 20 ns


# Set writeReg=00000
add_force writeReg 00000

# Set writeData=32'h00ffff00
add_force writeData 00ffff00 -radix hex

# Run the circuit for two clock cycles
run 20 ns


# Set writeReg=00100
add_force writeReg 00100

# Set writeData=32'habcdef12
add_force writeData abcdef12 -radix hex

# Run the circuit for two clock cycles
run 20 ns


# Set writeReg=00101
add_force writeReg 00101

# Set writeData=32'hffabffba
add_force writeData ffabffba -radix hex

# Run the circuit for two clock cycles
run 20 ns


#set write low
add_force write 0

# Run the circuit for one clock cycles
run 10 ns


# Set readReg1=00100 and readReg2=00101
add_force readReg1 00100
add_force readReg2 00101

# Run the circuit for one clock cycles
run 10 ns


# Set readReg1=00000 and readReg2=00000
add_force readReg1 00000
add_force readReg2 00000

# Run the circuit for one clock cycles
run 10 ns


# Set readReg1=00100 and readReg2=00011
add_force readReg1 00100
add_force readReg2 00011

# Run the circuit for one clock cycles
run 10 ns


# Set readReg1=00001 and readReg2=00010
add_force readReg1 00001
add_force readReg2 00010

# Run the circuit for one clock cycles
run 10 ns