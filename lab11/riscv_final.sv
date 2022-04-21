`timescale 1ns / 1ps
/***************************************************************************
* 
* Filename: riscv_final.sv
*
* Author: Travis Reynertson
* Class: ECEN 323,Section 002,Winter Semester 2022
* Date: 4/5/2022
*
* Description: 
* This module contains the basic pipeline for our RISC-V processor.
* It also contains logic to provide forwarding and control/hazard detection.
* It also has implemented all the Branch, Jump and ALU instructions needed.
* There are five stages to the pipeline that we are implementing here:
* Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write-Back.
*
****************************************************************************/
`include "riscv_basic_pipeline_constants.sv"
`include "riscv_alu_constants.sv"

module riscv_final #(parameter [31:0]INITIAL_PC = 32'h00400000)
(clk, rst, PC, instruction, ALUResult, dAddress, dWriteData, dReadData, MemRead, MemWrite, iMemRead, WriteBackData);


// Inputs
input wire logic clk;
input wire logic rst;
input wire logic [31:0] instruction;
input wire logic [31:0] dReadData;


// Outputs
output logic MemRead;
output logic MemWrite;
output logic iMemRead;
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
logic[31:0] id_readData1;
logic [31:0] id_readData2;
logic [31:0] id_itype_immediate;
logic [31:0] id_stype_immediate;
logic [31:0] id_branch_offset;

// ID Forwarding logic
logic [4:0] id_reg1, id_reg2;
logic [4:0]id_writeReg;

// ID Final logic
logic [31:0] id_utype_lui_immediate;
logic [3:0] id_func3;
logic [31:0] id_jal_immediate;
logic [31:0] id_jalr_immediate;
logic id_is_jalr;
logic id_is_jal;


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
logic[31:0] ex_readData1;
logic [31:0] ex_readData2;
logic ex_ALU_zero;
logic [31:0] ex_ALU_result;
logic [31:0] ex_PC_plus_Offset;
logic [31:0] ex_branch_offset;

// EX Forwarding logic
logic [4:0] ex_reg1, ex_reg2;
logic [4:0]ex_writeReg;

// EX final logic
logic ex_ALU_LESS_THAN;
logic [3:0] ex_func3;
logic ex_is_jalr;
logic ex_is_jal;


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
logic [31:0] mem_writeData;
logic mem_PCSrc;
logic [31:0] mem_readData2;

// MEM Forwarding logic
logic [4:0]mem_writeReg;
logic branch_mem_taken;

// MEM Final logic
logic mem_ALU_LESS_THAN;
logic [3:0] mem_func3;
logic mem_is_jalr;
logic mem_is_jal;


// Logic for WB stage
logic wb_RegWrite;
logic wb_MemtoReg;
logic [31:0] wb_writeData;
logic [31:0] wb_ALU_result;

// WB Forwarding logic
logic [4:0]wb_writeReg;
logic branch_wb_taken;


// To Top-Level
assign PC = if_PC;
assign ALUResult = ex_ALU_result;
assign dWriteData = mem_readData2;
assign MemWrite = mem_MemWrite;
assign MemRead = mem_MemRead;
assign dAddress = mem_ALU_result;
assign WriteBackData = wb_writeData;

// The load_use_hazard signal
logic load_use_hazard;
assign load_use_hazard = (ex_MemRead && !mem_PCSrc && 
                          ((ex_writeReg == id_reg1) || (ex_writeReg == id_reg2)))?1:0;
                          
// The branch taken signal in mem
// The wb branch taken signal is passed from mem to wb                          
assign branch_mem_taken = mem_PCSrc;

// this is the iMemRead signal
assign iMemRead = !load_use_hazard;

//////////////////////////////////////////////////////////////////////
// IF: Instruction Fetch
//////////////////////////////////////////////////////////////////////

// Resets and correctly increments if_PC	
// It also stalls the PC if needed
always_ff@(posedge clk)
begin
    if (rst)
    begin
        if_PC <= INITIAL_PC;
    end
    else if (load_use_hazard)
    begin
        //nothing, stall
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
// It also stalls the PC if needed
always_ff@(posedge clk)
begin
    if (rst)
    begin
        id_PC <= INITIAL_PC;
    end
    else if (load_use_hazard)
    begin
        //nothing, stall
    end  
    else
    begin
        id_PC <= if_PC;
    end
end

logic [3:0] func3;
logic [6:0] opcode;
logic func7;

assign func3 = instruction[14:12];

assign id_func3 = func3;

assign opcode = instruction[6:0];
       
assign func7 = instruction[30];


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
                    
                // NEW ALU STUFF
                else if (func3 == FUNC3_SLL)
                    id_ALUCtrl = ALUOP_SHIFT_LEFT;
                else if (func3 == FUNC3_SRL_SRA)
                    if (func7 == FUNC7_SRL)
                        id_ALUCtrl = ALUOP_SHIFT_RIGHT;
                    else
                        id_ALUCtrl = ALUOP_SHIFT_RIGHT_ARITH;
                    
                // ********************
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
                    
                // NEW ALU STUFF
                else if (func3 == FUNC3_SLL)
                    id_ALUCtrl = ALUOP_SHIFT_LEFT;
                else if (func3 == FUNC3_SRL_SRA)
                    if (func7 == FUNC7_SRL)
                        id_ALUCtrl = ALUOP_SHIFT_RIGHT;
                    else
                        id_ALUCtrl = ALUOP_SHIFT_RIGHT_ARITH;
                    
                // **********************
                else
                    id_ALUCtrl = ALUOP_ADD;
            U_TYPE_LUI:
                id_ALUCtrl = ALUOP_ADD;
            default:
                id_ALUCtrl = ALUOP_ADD;
        endcase
    end

// Immediates
assign id_itype_immediate = {{20{instruction[31]}},instruction[31:20]};
assign id_stype_immediate = {{20{instruction[31]}},instruction[31:25],instruction[11:7]};
assign id_branch_offset = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
assign id_utype_lui_immediate = {instruction[31:12],12'b0};

// immediate for jumps
assign id_jal_immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
assign id_jalr_immediate = {{20{instruction[31]}},instruction[31:20]};

// This finds the id_immediate
always_comb
begin
    id_is_jalr = 0;
    id_is_jal = 0;
    
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
            U_TYPE_LUI:
                id_immediate = id_utype_lui_immediate;
            UJ_TYPE:
                begin
                id_immediate = id_jal_immediate;
                id_is_jal = 1;
                end
            I_TYPE_JALR:
                begin
                id_immediate = id_jalr_immediate;
                id_is_jalr = 1;
                end
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
        else if (opcode == SB_TYPE ||
                opcode == UJ_TYPE ||
                opcode == I_TYPE_JALR)
            id_Branch = 1;
        else
            id_Branch = 0;
    end

// This finds the ALUSrc signal
always_comb
begin
    if (
        opcode == I_TYPE_IMM ||
        opcode == I_TYPE_LOAD ||
        opcode == S_TYPE ||
        opcode == U_TYPE_LUI ||
        opcode == UJ_TYPE ||
        opcode == I_TYPE_JALR
        )
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


assign id_reg1 = (opcode == U_TYPE_LUI)?5'b0:instruction[19:15];
assign id_reg2 = instruction[24:20];
assign id_writeReg = instruction[11:7];

// regfile
regfile myregfile (.clk(clk), .readReg1(id_reg1), .readReg2(id_reg2), 
.writeReg(wb_writeReg), .writeData(wb_writeData), .write(wb_RegWrite), .readData1(ex_readData1), .readData2(id_readData2));

//////////////////////////////////////////////////////////////////////
// EX: Execute
//////////////////////////////////////////////////////////////////////	

// Resets and corretly passes needed values
// It also inserts NOPs as needed
always_ff@(posedge clk)
begin
    if (rst || load_use_hazard || branch_mem_taken || branch_wb_taken)
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
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_func3 <= 0;
        ex_is_jalr <= 0;
        ex_is_jal <= 0;
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
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_func3 <= id_func3;
        ex_is_jalr <= id_is_jalr;
        ex_is_jal <= id_is_jal;
    end
end

logic [31:0] ex_op1, ex_op2, ex_julr;

// This is the forwarding unit to control ex_julr
always_comb
begin
    if (ex_reg1 == 0)
    begin
        ex_julr = 0;
    end
    else if (ex_reg1 == mem_writeReg)
    begin
        ex_julr = mem_ALU_result;
    end
    else if (ex_reg1 == wb_writeReg)
    begin
        ex_julr = wb_writeData;
    end
    else
    begin
        ex_julr = ex_readData1;
    end
end

// This is the forwarding unit to control ex_op1
always_comb
begin
    if (ex_is_jalr || ex_is_jal)
    begin
        ex_op1 = ex_PC;
    end
    else if (ex_reg1 == 0)
    begin
        ex_op1 = 0;
    end
    else if (ex_reg1 == mem_writeReg)
    begin
        ex_op1 = mem_ALU_result;
    end
    else if (ex_reg1 == wb_writeReg)
    begin
        ex_op1 = wb_writeData;
    end
    else
    begin
        ex_op1 = ex_readData1;
    end
end

// This is the forwarding unit to control ex_op2
always_comb
begin
    if (ex_is_jalr || ex_is_jal)
    begin
        ex_op2 = 4;
    end
    else if (ex_ALUSrc)
    begin
        ex_op2 = ex_immediate;
    end
    else if (ex_reg2 == 0)
    begin
        ex_op2 = 0;
    end
    else if (ex_reg2 == mem_writeReg)
    begin
        ex_op2 = mem_ALU_result;
    end
    else if (ex_reg2 == wb_writeReg)
    begin
        ex_op2 = wb_writeData;
    end
    else
    begin
        ex_op2 = ex_readData2;
    end
end


// ALU
alu myALU (.alu_op(ex_ALUCtrl), .op1(ex_op1), .op2(ex_op2), .zero(ex_ALU_zero), .result(ex_ALU_result));

// LESS THAN
assign ex_ALU_LESS_THAN = ex_ALU_result[31];

// Finds the correct branch target for PC
assign ex_PC_plus_Offset = (ex_is_jalr)?ex_julr + ex_immediate: ex_PC + ex_immediate;

// Forwarding for sw
always_comb
begin
    if (ex_reg2 == mem_writeReg)
    begin
        ex_readData2 = mem_ALU_result;
    end
    else if (ex_reg2 == wb_writeReg)
    begin
        ex_readData2 = wb_writeData;
    end
    else
    begin
        ex_readData2 = id_readData2;
    end
end

//////////////////////////////////////////////////////////////////////
// MEM: Memory Access
//////////////////////////////////////////////////////////////////////	

// Resets and corretly passes needed values
// It also inserts NOPs as needed
always_ff@(posedge clk)
begin
    if (rst || branch_mem_taken)
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
        mem_func3 <= 0;
        mem_is_jalr <= 0;
        mem_is_jal <= 0;
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
        mem_ALU_LESS_THAN <= ex_ALU_LESS_THAN; 
        mem_func3 <= ex_func3;   
        mem_is_jalr <= ex_is_jalr;
        mem_is_jal <= ex_is_jal;
    end
end

logic branch_go;

// Logic to determine if the branch should be taken
assign branch_go = (
                    (
                    (mem_func3 == FUNC3_BEQ && mem_ALU_zero) ||
                    (mem_func3 == FUNC3_BNE && !mem_ALU_zero) ||
                    (mem_func3 == FUNC3_BLT && mem_ALU_LESS_THAN) ||
                    (mem_func3 == FUNC3_BGE && !mem_ALU_LESS_THAN)
                    ) ||
                    mem_is_jalr || mem_is_jal
                    )?1:0;

// Sets mem_PCSrc signal
assign mem_PCSrc = (mem_Branch && branch_go);

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
        branch_wb_taken <= 0;
    end
    else
    begin
        wb_MemtoReg <= mem_MemtoReg;
        wb_RegWrite <= mem_RegWrite;
        wb_writeReg <= mem_writeReg;
        wb_ALU_result <= mem_ALU_result;
        
        branch_wb_taken <= branch_mem_taken;
    end
end

// Finds the correct writeback data
assign wb_writeData = (wb_MemtoReg)?dReadData:wb_ALU_result;


//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////


endmodule