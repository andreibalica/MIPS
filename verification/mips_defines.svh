`ifndef MIPS_DEFINES_SVH
`define MIPS_DEFINES_SVH

// --- Opcodes for Instructions ---
`define OPCODE_RTYPE  6'b000000
`define OPCODE_J      6'b000010
`define OPCODE_BEQ    6'b000100
`define OPCODE_BNE    6'b000101
`define OPCODE_ADDI   6'b001000
`define OPCODE_LW     6'b100011
`define OPCODE_SW     6'b101011
`define OPCODE_INV    6'b111111

// --- Function codes for R-Type Instructions ---
`define FUNCT_ADD     6'b100000
`define FUNCT_SUB     6'b100010
`define FUNCT_AND     6'b100100
`define FUNCT_OR      6'b100101
`define FUNCT_INV     6'b111111

// --- ALU Control codes (4-bit signal) ---
`define ALU_CTRL_AND  4'b0000
`define ALU_CTRL_OR   4'b0001
`define ALU_CTRL_ADD  4'b0010
`define ALU_CTRL_SUB  4'b0110

// --- ALUOp definitions (2-bit signal) ---
`define ALU_OP_LW_SW  2'b00
`define ALU_OP_BRANCH 2'b01
`define ALU_OP_RTYPE  2'b10

// --- Exception handling - Vectored Interrupts (Patterson & Hennessy) ---
`define UNDEFINED_HANDLER_ADDR  32'h80000000  // Undefined instruction handler
`define OVERFLOW_HANDLER_ADDR   32'h80000180  // Arithmetic overflow handler
`define EXCEPTION_LOOP_UNDEF    32'h08000000  // J 0x80000000 (jump to self)
`define EXCEPTION_LOOP_OVERFLOW 32'h08200060  // J 0x80000180 (jump to self)

`endif // MIPS_DEFINES_SVH
