`timescale 1ns / 1ps

/***************************************************************************
* 
* Filename: riscv_multicycle.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 2/15/2022
*
* Description: 
* This module controls the simple datapath module that we created last lab.
* It translates the instructions into useable data that is passed down to lower levels
*
****************************************************************************/
`include "riscv_alu_constants.sv"


module riscv_multicycle #(parameter [31:0]INITIAL_PC = 32'h00400000)
(clk, rst, instruction, MemWrite, MemRead, PC, dAddress, dWriteData, dReadData, WriteBackData);

    // Inputs
    input wire logic clk;
    input wire logic rst;
    input wire logic [31:0] instruction;
    input wire logic [31:0] dReadData;
    
    // outputs
    output logic [31:0] PC;
    output logic [31:0] dAddress;
    output logic [31:0] dWriteData;
    output logic MemRead;
    output logic MemWrite;
    output logic [31:0] WriteBackData;
    
      
    logic [3:0]ALUCtrl;
    logic ALUSrc, RegWrite, MemtoReg, loadPC, Zero, RegWrite_Temp, PCSrc;
    
    logic [3:0] func3;
    assign func3 =  instruction[14:12];
    
    logic [6:0] opcode;
    assign opcode = instruction[6:0];
    
    logic func7;
    assign func7 = instruction[30];
    
    // This finds the ALUCtrl signal
    always_comb
    begin
        case(opcode)
            R_TYPE:
            begin
                if (func3 == FUNC3_ADD_SUB)
                    if (instruction[30]) ALUCtrl = ALUOP_SUB;
                    else ALUCtrl = ALUOP_ADD;
                    
                else if (func3 == FUNC3_AND) ALUCtrl = ALUOP_AND;

                else if (func3 == FUNC3_OR) ALUCtrl = ALUOP_OR;

                else if (func3 == FUNC3_SHIFT_RIGHT)
                    if (func7) ALUCtrl = ALUOP_SHIFT_RIGHT_ARITH;
                    else ALUCtrl = ALUOP_SHIFT_RIGHT;
                
                else if (func3 == FUNC3_LESS_THAN) ALUCtrl = ALUOP_LESS_THAN;
                
                else if (func3 == FUNC3_XOR) ALUCtrl = ALUOP_XOR;

                else ALUCtrl = ALUOP_ADD;
            end
            
            SB_TYPE:
            begin
                ALUCtrl = ALUOP_SUB;
            end
            
            I_TYPE_IMM:
            begin
                if (func3 == FUNC3_ADD_SUB) ALUCtrl = ALUOP_ADD;
                    
                else if (func3 == FUNC3_AND) ALUCtrl = ALUOP_AND;

                else if (func3 == FUNC3_OR) ALUCtrl = ALUOP_OR;

                else if (func3 == FUNC3_SHIFT_RIGHT) ALUCtrl = ALUOP_SHIFT_RIGHT;
                
                else if (func3 == FUNC3_LESS_THAN) ALUCtrl = ALUOP_LESS_THAN;
                
                else if (func3 == FUNC3_XOR) ALUCtrl = ALUOP_XOR;

                else ALUCtrl = ALUOP_ADD;
            end
            
            default:
            begin
                ALUCtrl = ALUOP_ADD;
            end
            
        endcase  
    end
    
    // This finds the ALUSrc signal
    always_comb
    begin
        if (opcode == I_TYPE_IMM || instruction[6:0] == I_TYPE_LOAD || opcode == S_TYPE)
        begin
            ALUSrc = 1;
        end
        else
        begin
            ALUSrc = 0;
        end
    end
    
    logic MemRead_temp;
    
    // This finds the MemRead_temp signal that will be tied to MemRead
    always_comb
    begin
        if (opcode == I_TYPE_LOAD)
        begin
            MemRead_temp = 1;
        end
        else
        begin
            MemRead_temp = 0;
        end
    end
    
    logic MemWrite_temp;
    
    // This finds the MemWrite_temp signal that will be tied to MemWrite
    always_comb
    begin
        if (opcode == S_TYPE)
        begin
            MemWrite_temp = 1;
        end
        else
        begin
            MemWrite_temp = 0;
        end
    end
    
    // This finds the MemtoReg signal
    always_comb
    begin
        if (opcode == I_TYPE_LOAD)
        begin
            MemtoReg = 1;
        end
        else
        begin
            MemtoReg = 0;
        end
    end
    
    // This finds the PCSrc signal
    always_comb
    begin
        if (opcode == SB_TYPE && func3 == FUNC3_BEQ && Zero)
        begin
            PCSrc = 1;
        end
        else
        begin
            PCSrc = 0;
        end
    end
    
    // This finds the RegWrite_temp signal that ties to RegWrite
    always_comb
    begin
        case(opcode)
            SB_TYPE: RegWrite_Temp = 0;
            S_TYPE: RegWrite_Temp = 0;
            default: RegWrite_Temp = 1;
        endcase
    end
    
    
    typedef enum logic [2:0] {I_F, ID, EX, MEM, WB, ERR='X} stateType;
    stateType ns, cs;
    
    // This is the state machine of the module
    always_comb
    begin
        ns = ERR;
        RegWrite = 0;
        loadPC = 0;
        MemRead = 0;
        MemWrite = 0;
        
        if (rst)
        begin
            ns = I_F;
        end
        
        else
        begin
            case(cs)            
                I_F: ns = ID;
                
                ID: ns = EX;
            
                EX: ns = MEM;
                
                MEM:
                begin
                    MemRead = MemRead_temp;
                    MemWrite = MemWrite_temp;
                    ns = WB;
                end
                
                WB:
                begin
                    RegWrite = RegWrite_Temp;
                    loadPC = 1;
                    ns = I_F;
                end
                
                default:
                begin
                    
                end
            endcase
        end
    end
    
    // This sets the current state to the next state
    always_ff@(posedge clk)
    begin
        if (rst) cs <= I_F;
        else cs <= ns;
    end
    
        
     // Calling riscv_simple_datapath
    riscv_simple_datapath myDataPath (.clk(clk), .rst(rst), .instruction(instruction), .PCSrc(PCSrc),
    .ALUSrc(ALUSrc), .RegWrite(RegWrite), .MemtoReg(MemtoReg), .ALUCtrl(ALUCtrl), .loadPC(loadPC), .dReadData(dReadData),
    .PC(PC), .Zero(Zero), .dAddress(dAddress), .dWriteData(dWriteData), .WriteBackData(WriteBackData));
    
    


endmodule
