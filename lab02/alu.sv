`timescale 1ns / 1ps
/***************************************************************************
* 
* File: alu.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 1/11/2022
*
* Module: alu
*
* Description:
*    
*This module performs the simple calculations according to the instructions that it is given
*    
*    
*
****************************************************************************/

// Include the constants for the alu_op values
 `include "riscv_alu_constants.sv"


module alu(
    input wire logic [31:0] op1, op2,
    input wire logic [3:0] alu_op,
    output logic zero,
    output logic [31:0] result
    );
    
    // if result is value 0 then set zero to high
    // else set it to low
    assign zero = (result == 0)?1:0;
    
    // This always_comb block performs the correct calculation on op1 and op2\
    // according to the given alu_op value.
    // The resulting calculation of op1 and op2 will go into result
    always_comb begin
        case(alu_op) 
            ALUOP_AND:
            result = op1 & op2;
        
            ALUOP_OR:
            result = op1 | op2;
            
            ALUOP_ADD:
            result = op1 + op2;
            
            ALUOP_SUB:
            result = op1 - op2;
            
            ALUOP_LESS_THAN:
            result = $signed(op1) < $signed(op2);
            
            ALUOP_SHIFT_RIGHT:
            result = op1 >> op2[4:0];
            
            ALUOP_SHIFT_LEFT:
            result = op1 << op2[4:0];
            
            ALUOP_SHIFT_RIGHT_ARITH:
            result = $unsigned($signed(op1) >>> op2[4:0]);
            
            ALUOP_XOR:
            result = op1 ^ op2;
            
            default:
            result = op1 + op2;
          endcase 
    end
    
    
endmodule
