`timescale 1ns / 1ps
/***************************************************************************
* 
* Filename: riscv_basic_pipeline.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 3/8/2022
*
* Description: 
* This module contains the basic pipeline for our RISC-V processor.
* There are five stages to the pipeline that we are implementing here:
* Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write-Back.
*
****************************************************************************/
`include "riscv_basic_pipeline_constants.sv"
`include "riscv_alu_constants.sv"

module riscv_basic_pipeline #(parameter [31:0]INITIAL_PC = 32'h00400000)
(clk, rst, PC, instruction, ALUResult, dAddress, dWriteData, dReadData, MemRead, MemWrite, WriteBackData);


// Inputs
input wire logic clk;
input wire logic rst;
input wire logic [31:0] instruction;
input wire logic [31:0] dReadData;


// Outputs
output logic MemRead;
output logic MemWrite;
output logic [31:0] PC;
output logic [31:0] ALUResult;
output logic [31:0] dAddress;
output logic [31:0] dWriteData;
output logic [31:0] WriteBackData;


// Logic for IF stage
logic [31:0]if_PC;


// Logic for ID stage
logic [31:0]id_PC;
logic [3:0]id_ALUCtrl;
logic id_ALUSrc;
logic id_MemWrite;
logic id_MemRead;
logic id_Branch;
logic id_RegWrite;
logic id_MemtoReg;
logic [31:0] id_immediate;
logic [4:0]id_writeReg;
logic[31:0] id_readData1;
logic [31:0] id_readData2;
logic [31:0] id_itype_immediate;
logic [31:0] id_stype_immediate;
logic [31:0] id_branch_offset;


// Logic for EX stage
logic [31:0]ex_PC;
logic ex_ALUSrc;
logic ex_MemWrite;
logic ex_MemRead;
logic ex_Branch;
logic ex_RegWrite;
logic ex_MemtoReg;
logic [3:0]ex_ALUCtrl;
logic [31:0] ex_PC_Offset;
logic [31:0] ex_immediate;
logic [4:0]ex_writeReg;
logic[31:0] ex_readData1;
logic [31:0] ex_readData2;
logic ex_ALU_zero;
logic [31:0] ex_ALU_result;
logic [31:0] ex_PC_plus_Offset;
logic [31:0] ex_branch_offset;


// Logic for MEM stage
logic [31:0]mem_PC;
logic mem_RegWrite;
logic mem_MemtoReg;
logic mem_Branch;
logic mem_MemRead;
logic mem_MemWrite;
logic [31:0] mem_PC_plus_Offset;
logic mem_ALU_zero;
logic [31:0] mem_ALU_result;
logic [4:0]mem_writeReg;
logic [31:0] mem_writeData;
logic mem_PCSrc;
logic [31:0] mem_readData2;


// Logic for WB stage
logic [4:0]wb_writeReg;
logic wb_RegWrite;
logic wb_MemtoReg;
logic [31:0] wb_writeData;
logic [31:0] wb_ALU_result;


// To Top-Level
assign PC = if_PC;
assign ALUResult = ex_ALU_result;
assign dWriteData = mem_readData2;
assign MemWrite = mem_MemWrite;
assign MemRead = mem_MemRead;
assign dAddress = mem_ALU_result;
assign WriteBackData = wb_writeData;


//////////////////////////////////////////////////////////////////////
// IF: Instruction Fetch
//////////////////////////////////////////////////////////////////////

// Resets and correctly increments if_PC	
always_ff@(posedge clk)
begin
    if (rst)
    begin
        if_PC <= INITIAL_PC;
    end
    else
    begin
        if (mem_PCSrc)
        begin
            if_PC <= mem_PC_plus_Offset;
        end
        else
        begin
            if_PC <= if_PC + 4;
        end
    end
end

//////////////////////////////////////////////////////////////////////
// ID: Instruction Decode
//////////////////////////////////////////////////////////////////////

// Resets and corretly passes needed values
always_ff@(posedge clk)
begin
    if (rst)
    begin
        id_PC <= INITIAL_PC;
    end
    else
    begin
        id_PC <= if_PC;
    end
end

logic [3:0] func3;
assign func3 = instruction[14:12];

logic [6:0] opcode;
assign opcode = instruction[6:0];

logic func7;
assign func7 = instruction[30];

logic [4:0] reg1, reg2;

// This finds the ALUCtrl signal
always_comb
    begin
        id_ALUCtrl = ALUOP_ADD;
        if (rst)
            id_ALUCtrl = ALUOP_ADD;
        case(opcode)
            I_TYPE_IMM:
                if (func3 == FUNC3_AND)
                    id_ALUCtrl = ALUOP_AND;
                else if (func3 == FUNC3_OR)
                    id_ALUCtrl = ALUOP_OR;
                else if(func3 == FUNC3_ADD_SUB)
                    id_ALUCtrl = ALUOP_ADD;
                else if (func3 == FUNC3_XOR)
                    id_ALUCtrl = ALUOP_XOR;
                else if (func3 == FUNC3_LESS_THAN)
                    id_ALUCtrl = ALUOP_LESS_THAN;
                else
                    id_ALUCtrl = ALUOP_ADD;
            I_TYPE_LOAD:
                id_ALUCtrl = ALUOP_ADD;
            S_TYPE:
                id_ALUCtrl = ALUOP_ADD;
            SB_TYPE:
                id_ALUCtrl = ALUOP_SUB;
            R_TYPE:
                if (func3 == FUNC3_AND)
                    id_ALUCtrl = ALUOP_AND;
                else if (func3 == FUNC3_OR)
                    id_ALUCtrl = ALUOP_OR;
                else if((func3 == FUNC3_ADD_SUB) && (func7 == 0))
                    id_ALUCtrl = ALUOP_ADD;
                else if ((func3 == FUNC3_ADD_SUB) && (func7 == 1))
                    id_ALUCtrl = ALUOP_SUB;
                else if (func3 == FUNC3_XOR)
                    id_ALUCtrl = ALUOP_XOR;
                else if (func3 == FUNC3_LESS_THAN)
                    id_ALUCtrl = ALUOP_LESS_THAN;
                else
                    id_ALUCtrl = ALUOP_ADD;
            default:
                id_ALUCtrl = ALUOP_ADD;
        endcase
    end

assign id_itype_immediate = {{20{instruction[31]}},instruction[31:20]};
assign id_stype_immediate = {{20{instruction[31]}},instruction[31:25],instruction[11:7]};
assign id_branch_offset = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};

// This finds the id_immediate
always_comb
begin
    if (rst)
    begin
        id_immediate = 0;
    end
    else
    begin
        case(opcode)
            I_TYPE_IMM:
                id_immediate = id_itype_immediate;
            I_TYPE_LOAD:
                id_immediate = id_itype_immediate;
            SB_TYPE:
                id_immediate = id_branch_offset;
            S_TYPE:
                id_immediate = id_stype_immediate;
            default:
                id_immediate = 0;
         endcase
    end
end

// This finds the id_Branch signal
always_comb
    begin
        id_Branch = 0;
        if (rst)
            id_Branch = 0;
        else if (opcode == SB_TYPE)
            id_Branch = 1;
        else
            id_Branch = 0;
    end

// This finds the ALUSrc signal
always_comb
begin
    if (opcode == I_TYPE_IMM || instruction[6:0] == I_TYPE_LOAD || opcode == S_TYPE)
    begin
        id_ALUSrc = 1;
    end
    else
    begin
        id_ALUSrc = 0;
    end
end

// This finds the MemRead_temp signal that will be tied to MemRead
always_comb
begin
    if (rst)
    begin
        id_MemRead = 0;
    end
    else
    begin
        if (opcode == I_TYPE_LOAD)
        begin
            id_MemRead = 1;
        end
        else
        begin
            id_MemRead = 0;
        end
    end
end

// This finds the MemWrite_temp signal that will be tied to MemWrite
always_comb
begin
    if (rst)
    begin
        id_MemWrite = 0;
    end
    else
    begin
        if (opcode == S_TYPE)
        begin
            id_MemWrite = 1;
        end
        else
        begin
            id_MemWrite = 0;
        end
    end
end

// This finds the MemtoReg signal
always_comb
begin
    if (rst)
    begin
        id_MemtoReg = 0;
    end
    else
    begin
        if (opcode == I_TYPE_LOAD)
        begin
            id_MemtoReg = 1;
        end
        else
        begin
            id_MemtoReg = 0;
        end
    end
end

// This finds the RegWrite_temp signal that ties to RegWrite
always_comb
begin
    if (rst)
    begin
        id_RegWrite = 0;
    end
    else
    begin
        case(opcode)
            SB_TYPE: id_RegWrite = 0;
            S_TYPE: id_RegWrite = 0;
            default: id_RegWrite = 1;
        endcase
    end
end


assign reg1 = instruction[19:15];
assign reg2 = instruction[24:20];
assign id_writeReg = instruction[11:7];

// regfile
regfile myregfile (.clk(clk), .readReg1(reg1), .readReg2(reg2), 
.writeReg(wb_writeReg), .writeData(wb_writeData), .write(wb_RegWrite), .readData1(ex_readData1), .readData2(ex_readData2));


//////////////////////////////////////////////////////////////////////
// EX: Execute
//////////////////////////////////////////////////////////////////////	

// Resets and corretly passes needed values
always_ff@(posedge clk)
begin
    if (rst)
    begin
        ex_PC <= INITIAL_PC;
        ex_ALUCtrl <= ALUOP_ADD;
        ex_ALUSrc <= 0;
        ex_MemWrite <= 0;
        ex_MemRead <= 0;
        ex_Branch <= 0;
        ex_RegWrite <= 0;
        ex_MemtoReg <= 0;
        ex_immediate <= 0;
        ex_writeReg <= 0;
        ex_branch_offset <= 0;
    end
    else
    begin
        ex_PC <= id_PC;
        ex_ALUCtrl <= id_ALUCtrl;
        ex_ALUSrc <= id_ALUSrc;
        ex_MemWrite <= id_MemWrite;
        ex_MemRead <= id_MemRead;
        ex_Branch <= id_Branch;
        ex_RegWrite <= id_RegWrite;
        ex_MemtoReg <= id_MemtoReg;
        ex_immediate <= id_immediate;
        ex_writeReg <= id_writeReg;
        ex_branch_offset <= id_branch_offset;
    end
end

logic [31:0] ex_op2;
assign ex_op2 = (ex_ALUSrc)?ex_immediate:ex_readData2;

// ALU
alu myALU (.alu_op(ex_ALUCtrl), .op1(ex_readData1), .op2(ex_op2), .zero(ex_ALU_zero), .result(ex_ALU_result));

// Finds the correct branch target for PC
assign ex_PC_plus_Offset = ex_PC + ex_branch_offset;

//////////////////////////////////////////////////////////////////////
// MEM: Memory Access
//////////////////////////////////////////////////////////////////////	

// Resets and corretly passes needed values
always_ff@(posedge clk)
begin
    if (rst)
    begin
        mem_PC <= 0;
        mem_RegWrite <= 0;
        mem_MemtoReg <= 0;
        mem_Branch <= 0;
        mem_MemRead <= 0;
        mem_MemWrite <= 0;
        mem_PC_plus_Offset <= 0;
        mem_ALU_zero <= 0;
        mem_ALU_result <= 0;
        mem_writeReg <= 0;
        mem_readData2 <= 0;
    end
    else
    begin
        mem_PC <= ex_PC;
        mem_RegWrite <= ex_RegWrite;
        mem_MemtoReg <= ex_MemtoReg;
        mem_Branch <= ex_Branch;
        mem_MemRead <= ex_MemRead;
        mem_MemWrite <= ex_MemWrite;
        mem_PC_plus_Offset <= ex_PC_plus_Offset;
        mem_ALU_zero <= ex_ALU_zero;
        mem_ALU_result <= ex_ALU_result;
        mem_writeReg <= ex_writeReg;  
        mem_readData2 <= ex_readData2;     
    end
end

// Sets mem_PCSrc signal
assign mem_PCSrc = (mem_Branch && mem_ALU_zero);

//////////////////////////////////////////////////////////////////////
// WB: Write-Back
//////////////////////////////////////////////////////////////////////	

// Resets and corretly passes needed values
always_ff@(posedge clk)
begin
    if (rst)
    begin
        wb_MemtoReg <= 0;
        wb_RegWrite <= 0;
        wb_writeReg <= 0;
        wb_ALU_result <= 0;
    end
    else
    begin
        wb_MemtoReg <= mem_MemtoReg;
        wb_RegWrite <= mem_RegWrite;
        wb_writeReg <= mem_writeReg;
        wb_ALU_result <= mem_ALU_result;
    end
end

// Finds the correct writeback data
assign wb_writeData = (wb_MemtoReg)?dReadData:wb_ALU_result;

endmodule
