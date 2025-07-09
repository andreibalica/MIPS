`timescale 1ns / 1ps
`include "mips_defines.sv"

module alu(
    input  logic [31:0] op1,
    input  logic [31:0] op2,
    input  logic [3:0]  alu_control,
    output logic [31:0] res,
    output logic        zero
    );
    
    always_comb begin
        case(alu_control)
            `ALU_CTRL_AND: begin // and
                res = op1 & op2;
            end
            `ALU_CTRL_OR: begin // or
                res = op1 | op2;
            end
            `ALU_CTRL_ADD: begin // add(i)/lw/sw
                res = op1 + op2;
            end
            `ALU_CTRL_SUB: begin // sub/beq
                res = op1 - op2;
            end
            default: begin
                res = 32'dX;
            end
        endcase
    end
    
    assign zero = (res == 32'd0);
endmodule
