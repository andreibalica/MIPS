`ifndef MIPS_DEFINES_SV
`define MIPS_DEFINES_SV

// --- Opcode-uri pentru Instructiuni ---
`define OPCODE_RTYPE  6'b000000
`define OPCODE_J      6'b000010
`define OPCODE_BEQ    6'b000100
`define OPCODE_BNE    6'b000101
`define OPCODE_ADDI   6'b001000
`define OPCODE_ANDI   6'b001100
`define OPCODE_ORI    6'b001101
`define OPCODE_LW     6'b100011
`define OPCODE_SW     6'b101011

// --- Coduri 'funct' pentru R-Type ---
`define FUNCT_ADD     6'b100000
`define FUNCT_SUB     6'b100010
`define FUNCT_AND     6'b100100
`define FUNCT_OR      6'b100101

// --- Coduri pentru Controlul ALU (semnalul de 4 biti) ---
`define ALU_CTRL_AND  4'b0000
`define ALU_CTRL_OR   4'b0001
`define ALU_CTRL_ADD  4'b0010
`define ALU_CTRL_SUB  4'b0110

// --- Definitii pentru ALUOp (semnalul de 2 biti) ---
`define ALU_OP_LW_SW  2'b00
`define ALU_OP_BRANCH 2'b01
`define ALU_OP_RTYPE  2'b10

`endif // MIPS_DEFINES_SV