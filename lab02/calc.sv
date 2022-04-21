`timescale 1ns / 1ps
/***************************************************************************
* 
* File: calc.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 1/11/2022
*
* Module: calc
*
* Description:
*    
*This module operates the calculations done in alu.
*It is in other words the top level module that connnects/operates the alu module
*    
*
****************************************************************************/

// Include the constants for the alu_op values
`include "riscv_alu_constants.sv"

module calc(
input wire logic clk, btnc, btnl, btnu, btnr, btnd,
input wire logic [15:0] sw,
output logic [15:0] led
    );
    
    logic [31:0] op1_calc, op2_calc;
    logic [3:0] alu_op_calc;
    logic zero;
    logic [31:0] result_calc;
    
    logic [15:0] accumulator;
    
    // This gets the accumulator value and puts it into op1_calc
    assign op1_calc = {{16{accumulator[15]}} , accumulator};
    
    // This gets the sw values and puts it into the op2_calc
    assign op2_calc = {{16{sw[15]}} , sw};
    
    // This is where we are calling/using the alu module.
    alu my_alu (.op1(op1_calc), .op2(op2_calc), .alu_op(alu_op_calc), .zero(zero), .result(result_calc));
    
    logic btnd_d, go, accum_change;
    
    // This is where we are using the OneShot module
    // btnu can reset the OneShot module
    OneShot activate (.clk(clk), .rst(btnu), .in(btnd), .os(accum_change));
    
    // This is we clear the value of the accumulator if btnu is pressed.
    // This is also where accumulator gets the lower 16 result bits when accum_change goes high from the OneShot
    always_ff@ (posedge clk)
        begin
            if (btnu)
                accumulator <= 0;
            else if (accum_change)
                accumulator <= result_calc[15:0];
        end
    
    // Led gets the accumulator values
    assign led = accumulator;
    
    logic [2:0] btn;
    
    // btn gets the values of btnl, btnc and btnr
    assign btn = {btnl,btnc,btnr};
    
    // alu_op_calc gets the alu instruction value according the the value of btn
    assign alu_op_calc = (!btnl & !btnc & !btnr)?ALUOP_ADD:
                         (!btnl & !btnc & btnr)?ALUOP_SUB:
                         (!btnl & btnc & !btnr)?ALUOP_AND:
                         (!btnl & btnc & btnr)?ALUOP_OR:
                         (btnl & !btnc & !btnr)?ALUOP_XOR:
                         (btnl & !btnc & btnr)?ALUOP_LESS_THAN:
                         (btnl & btnc & !btnr)?ALUOP_SHIFT_LEFT:
                         (btnl & btnc & btnr)?ALUOP_SHIFT_RIGHT_ARITH:
                          0;
    
endmodule
