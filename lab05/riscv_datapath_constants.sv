
`ifndef RISCV_DATAPATH_CONSTANTS
`define RISCV_DATAPATH_CONSTANTS

// Add all your constants here
localparam [31:0]INITIAL_PC = 32'h00400000;
localparam SIGN_EXTEND_VALUE = 20;
localparam S_TYPE_OPCODE = 7'b0100011;
localparam PC_UPDATE = 4'b0100;

`endif // RISCV_DATAPATH_CONSTANTS