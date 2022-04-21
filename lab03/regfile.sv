`timescale 1ns / 1ps
/***************************************************************************
* 
* File: regfile.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 1/19/2022
*
* Module: regfile
*
* Description:
*    
* This module performs contains the register and performs the simple instructions
* to write to the correct register values and and read from those registers.
*    
*    
*
****************************************************************************/


module regfile(clk, readReg1, readReg2, writeReg, writeData, write, readData1, readData2);

    input wire logic clk;
    input wire logic [4:0] readReg1;
    input wire logic [4:0] readReg2;
    input wire logic [4:0] writeReg;
    input wire logic [31:0] writeData;
    input wire logic write;
    output logic [31:0] readData1;
    output logic [31:0] readData2;
    
    // Declare multi-dimensional logic array (32 words, 32 bits each)
    logic [31:0] register[31:0];
    
    // Initialize the 32 words to zero
    integer i;
    initial
      for (i=0;i<32;i=i+1)
        register[i] = 0;
        
        
    // This is where readData1 and readData2 gets assigned the correct values.
    // This is also where the register will get assigned values if write is high
    // If the writeReg is equal to 0 then nothing will be written to register[0]
    // If readReg1 equals writeReg then readData1 will directly receive the value of writeData.
    // If readReg2 equals writeReg then readData2 will directly receive the value of writeData.
    always_ff@(posedge clk) begin
        readData1 <= register[readReg1];
        readData2 <= register[readReg2];
        if (write && writeReg != 0) begin
          register[writeReg] <= writeData;
          if (readReg1 == writeReg)
              readData1 <= writeData;
          if (readReg2 == writeReg)
              readData2 <= writeData;
       end
     end
    
endmodule
