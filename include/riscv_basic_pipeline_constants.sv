`ifndef RISCV_BASIC_PIPELINE_CONSTANTS
`define RISCV_BASIC_PIPELINE_CONSTANTS

// Add all your constants here
// Pipeline Constants
localparam R_TYPE = 7'b0110011;
localparam FUNC3_ADD_SUB = 3'b000;
localparam FUNC3_AND = 3'b111;
localparam FUNC3_OR = 3'b110;
localparam FUNC3_SHIFT_RIGHT = 3'b101;
localparam FUNC3_LESS_THAN = 3'b010;
localparam FUNC3_XOR = 3'b100;

localparam SB_TYPE = 7'b1100011;

localparam I_TYPE_IMM = 7'b0010011;
localparam I_TYPE_LOAD = 7'b0000011;
localparam S_TYPE = 7'b0100011;

// For final
localparam U_TYPE_LUI = 7'b0110111;

localparam FUNC3_BEQ = 3'b000;
localparam FUNC3_BNE = 3'b001;
localparam FUNC3_BLT = 3'b100;
localparam FUNC3_BGE = 3'b101;

localparam FUNC3_SLL = 3'b001;
localparam FUNC3_SRL_SRA = 3'b101;
localparam FUNC7_SRL = 7'b0000000;
localparam FUNC7_SRA = 7'b0100000;

localparam UJ_TYPE = 7'b1101111;
localparam I_TYPE_JALR = 7'b1100111;


`endif // RISCV_BASIC_PIPELINE_CONSTANTS