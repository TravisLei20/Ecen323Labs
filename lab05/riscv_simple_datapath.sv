`timescale 1ns / 1ps

/***************************************************************************
* 
* Filename: riscv_simple_datapath.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 2/7/2022
*
* Description: 
* This module performs the simple operations layed out in figure 4.19 of the 
* text book. It has the datapath of figure 4.11 with necessary multiplexers and control lines
*
****************************************************************************/

`include "riscv_datapath_constants.sv"

module riscv_simple_datapath #(parameter [31:0]INITIAL_PC = 32'h00400000)
(clk, rst, instruction, PCSrc, ALUSrc, RegWrite, MemtoReg, ALUCtrl, loadPC, PC, Zero, dAddress, dWriteData, dReadData, WriteBackData);

    // Inputs
    input wire logic clk;
    input wire logic rst;
    input wire logic [31:0] instruction;
    input wire logic PCSrc;
    input wire logic ALUSrc;
    input wire logic RegWrite;
    input wire logic MemtoReg;
    input wire logic [3:0]ALUCtrl;
    input wire logic loadPC;
    input wire logic [31:0] dReadData;
    
    // outputs
    output logic [31:0] PC;
    output logic Zero;
    output logic [31:0] dAddress;
    output logic [31:0] dWriteData;
    output logic [31:0] WriteBackData;
    
    // This is where PC gets its initial values if rst goes high
    // This is also where PC gets updated according the loadPC and PCSrc
    always_ff@(posedge clk)
    begin
        if (rst)
        begin
            PC <= INITIAL_PC;
        end
        
        else if (loadPC)
        begin
            if (PCSrc)
            begin
                PC <= PC + {{19{instruction[31]}},instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            
            else
            begin
                PC <= PC + PC_UPDATE;
            end
        end        
    end
    
    logic [31:0] outReadData1, outReadData2;
    
    // This is where regfile is called
    regfile myRegFile (.clk(clk), .readReg1(instruction[19:15]), .readReg2(instruction[24:20]),
    .writeReg(instruction[11:7]), .writeData(WriteBackData), .write(RegWrite),
    .readData1(outReadData1), .readData2(outReadData2));
    
    logic [31:0]immI,immS;
     
    // This gets the immediate data for type I and type S
    always_comb
    begin
        immI = {{SIGN_EXTEND_VALUE{instruction[31]}},instruction[31:20]};
        immS = {{SIGN_EXTEND_VALUE{instruction[31]}},instruction[31:25],instruction[11:7]};
    end
    
    logic [31:0] toOp2;
    
    // This assigns toOp2 to the correct value according to the instruction opcode value
    always_comb
    begin
        if (ALUSrc)
        begin
            if (instruction[6:0] == S_TYPE_OPCODE)
            begin
                toOp2 = immS;
            end
            else
            begin
                toOp2 = immI;
            end
        end
        else
        begin
            toOp2 = outReadData2;
        end
    end
    
    
    logic [31:0] aluResult;
    
    // This is where alu is called
    alu myALU (.alu_op(ALUCtrl), .op1(outReadData1), .op2(toOp2), .zero(Zero), .result(aluResult));
    
    // Set dAddress to aluResult and dWriteData to outReadData2
    assign dAddress = aluResult;
    assign dWriteData = outReadData2;
    
    // This is the multiplexer that gives writebackdata the correct value according to memtoreg value
    assign WriteBackData = (MemtoReg)?dReadData:aluResult;

endmodule
