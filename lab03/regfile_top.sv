`timescale 1ns / 1ps
/***************************************************************************
* 
* File: regfile_top.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 1/19/2022
*
* Module: regfile_top
*
* Description:
*    
* This module controls the top level of our register file.
* It connects/controls the buttons and switches to the regfile and alu
*    
*
****************************************************************************/


module regfile_top(clk,btnc, btnl, btnu, btnd, sw, led);
    
    input wire logic clk;
    input wire logic btnc;
    input wire logic btnl;
    input wire logic btnu;
    input wire logic btnd;
    input wire logic [15:0] sw;
    output logic [15:0] led;
    
    // This is the local parameter that will be used to sign extend
    localparam SIGN_EXTEND_VALUE = 17;
    
    // This is our 15 bit addressRegister
    logic [14:0] addressRegister;
    
    // This is where addressRegister will be set to zero if btnu is set high.
    // This is also where addressRegister gets the lower 15 bits of switches
    // if btnl is set high.
    always_ff@(posedge clk)
    begin
        if (btnu)
            addressRegister <= 0;
        else if (btnl)
            addressRegister <= sw[14:0];
    end
    
    // This is the logical logic that is required to create a synchronizer and one-shot circuit for btnc
    logic btnc_d, go_btnc, write;
    
    
    // This is our synchronizer for btnc
    // If btnu is set high then the local logic is reset to 0.
    always_ff@(posedge clk)
    begin
        if (btnu) begin
            btnc_d <= 0;
            go_btnc <= 0;
            
        end
        else begin
            btnc_d <= btnc;
            go_btnc <= btnc_d;
            
        end
    end
    
    // This is our one shot for btnc
    OneShot os1 (.clk(clk), .rst(btnu), .in(go_btnc), .os(write));
    
    // This is our local logic that is used to connect alu to regfile and vise-versa
    logic [31:0] toOp1, toOp2;
    logic [31:0] result;
    logic zero;
    
    // This is our alu instance
    alu myAlu (.result(result), .zero(zero), .alu_op(sw[3:0]), .op1(toOp1), .op2(toOp2));
    
    // This is the local logic that connects to the regfile port writeData
    logic [31:0] toWriteData;
    
    // This is where toWriteData gets assigned a value.
    // When sw[15]=1, the multiplexer will pass a 32-bit sign-extended value of the lower 15 switches.
    // When sw[15]=0, the multiplexer will pass the result from alu to toWriteData
    assign toWriteData = (sw[15]) ? {{SIGN_EXTEND_VALUE{sw[14]}},sw[14:0]} : result;
    
    
    // This is our instance of regfile
    regfile myReg (.clk(clk), .write(write), .writeData(toWriteData), .writeReg(addressRegister[14:10]),
    .readReg2(addressRegister[9:5]), .readReg1(addressRegister[4:0]), .readData1(toOp1), .readData2(toOp2));
    
    
    // This is a multiplexer that selects the lower 16-bits of the readReg1 when 'btnd' is NOT pressed
    // and selects the upper 16-bits of the readReg1 signal when 'btnd' IS pressed.
    assign led = (btnd)?toOp1[31:16]:toOp1[15:0];
    
    
    
endmodule
