#########################################################################
# 
# Filename: buttoncount.s
#
# Author: Travis Reynertson
# Class: EcEn 323 Winter semester
# Date: 2/17/2021
#
# Description: 
# This system:
# The value of the switches are continuously copied to the seven segment display
# Increment the LEDs by 1 when BTNU is pressed
# Decrement the LEDs by 1 when BTND is pressed
# Clear the LEDs when BTNC is pressed.
#
#########################################################################

.globl  main

.data
    .word 0

.text


# I/O address offset constants
    .eqv LED_OFFSET 0x0
    .eqv SWITCH_OFFSET 0x4
    .eqv SEVENSEG_OFFSET 0x18
    .eqv BUTTON_OFFSET 0x24

# I/O mask constants
    .eqv BUTTON_C_MASK 0x01
    .eqv BUTTON_D_MASK 0x04
    .eqv BUTTON_U_MASK 0x10

main:
    # Prepare I/O base address
    addi gp, x0, 0x7f
    # Add x3 to itself 8 times (0x7f << 8 = 0x7f00)
    addi t0, x0, 8
L1:
    add gp, gp, gp
    addi t0, t0, -1
    beq t0, x0, L2
    beq x0, x0, L1
L2:
    # Clear seven segment display
    sw x0, SEVENSEG_OFFSET(gp)          

LOOP_START:

    # Load the buttons
    lw s0, BUTTON_OFFSET(gp)
    # Mask the buttons for button C
    andi t0, s0, BUTTON_C_MASK
    # If button is not pressed, skip btnc code
    beq t0, x0, WRITE_LED_AND_SEVEN_SEGMENT
    # Button C pressed - fall through to clear LEDs
    # Clear LED
    sw x0, LED_OFFSET(gp)
    # Don't process other buttons          
    beq x0, x0, LOOP_START        

# Check btnd
BTND_CHK:

    # Check button D:
    andi t0, s0, BUTTON_D_MASK
    # If button is not pressed, skip
    beq t0, x0, BTNU_CHK
    # Button D pressed
    
#OneShot for btnd
LOOP_BTND:
    # Load the buttons
    lw s0, BUTTON_OFFSET(gp)
    # Check button D:
    andi t0, s0, BUTTON_D_MASK
    # Check if button still pressed
    xori t0, t0, BUTTON_D_MASK
    # Load switches 
    lw a0, SWITCH_OFFSET(gp)       
    # Update seven segment
    sw a0, SEVENSEG_OFFSET(gp)     
    # If button D is still pressed then loop back
    beq x0, t0, LOOP_BTND
    
    # Subtract 1
    addi s2, x0, -1
    # Go to write the LEDs
    beq x0, x0, WRITE_LED_AND_SEVEN_SEGMENT

# Check btnu
BTNU_CHK:
    # Mask the buttons for button U
    andi t0, s0, BUTTON_U_MASK
    # If button is not pressed, skip
    beq t0, x0, WRITE_LED_AND_SEVEN_SEGMENT
    # Button U pressed  
 
#OneShot   
LOOP_BTNU:
    # Load the buttons
    lw s0, BUTTON_OFFSET(gp)
    # Check button D:
    andi t0, s0, BUTTON_U_MASK
    # Check if button still pressed
    xori t0, t0, BUTTON_U_MASK
    # Load switches 
    lw a0, SWITCH_OFFSET(gp)       
    # Update seven segment
    sw a0, SEVENSEG_OFFSET(gp) 
    # If button D is still pressed then loop back
    beq x0, t0, LOOP_BTNU
       
    # Add 1         
    addi s2, x0, 1      
    beq x0, x0, WRITE_LED_AND_SEVEN_SEGMENT

# Write to the LEDs and Seven Segments
WRITE_LED_AND_SEVEN_SEGMENT:
    # Update LEDs
    sw s2, LED_OFFSET(gp)
    # Load switches 
    lw a0, SWITCH_OFFSET(gp)       
    # Update seven segment
    sw a0, SEVENSEG_OFFSET(gp)
    # Restart Loop 
    beq x0, x0, LOOP_START

