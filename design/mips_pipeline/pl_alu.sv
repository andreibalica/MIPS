`timescale 1ns / 1ps
`include "pl_mips_defines.svh"

module pl_alu(
    input  logic [31:0] op1,
    input  logic [31:0] op2,
    input  logic [3:0]  alu_control,
    output logic [31:0] res,
    output logic        zero,
    output logic        overflow
    );
    
    always_comb begin
        overflow = 1'b0;
        
        case(alu_control)
            `ALU_CTRL_AND: begin // and
                res = op1 & op2;
            end
            `ALU_CTRL_OR: begin // or
                res = op1 | op2;
            end
            `ALU_CTRL_ADD: begin // add(i)/lw/sw
                res = op1 + op2;
                overflow = (op1[31] == op2[31]) && (res[31] != op1[31]);
            end
            `ALU_CTRL_SUB: begin // sub/beq/bne
                res = op1 - op2;
                overflow = (op1[31] != op2[31]) && (res[31] == op2[31]);
            end
            default: begin
                res = 32'dX;
            end
        endcase
    end
    
    assign zero = (res == 32'd0);
endmodule
