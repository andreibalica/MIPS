`timescale 1ns / 1ps
`include "pl_mips_defines.svh"

module pl_alu_control(
    input  logic [5:0] funct,
    input  logic [1:0] alu_op,
    output logic [3:0] alu_control,
    output logic       undefined_instr
    );
    
    always_comb begin
        alu_control = 4'bX;
        undefined_instr = 1'b0;

        case(alu_op)
            // Type I (lw/sw/addi)
            `ALU_OP_LW_SW: begin
                alu_control = `ALU_CTRL_ADD;
            end
            // Type Jump - Conditional
            `ALU_OP_BRANCH: begin
                alu_control = `ALU_CTRL_SUB;
            end
            // Type R
            `ALU_OP_RTYPE: begin
                case(funct)
                    `FUNCT_ADD: // add
                        alu_control = `ALU_CTRL_ADD;
                    `FUNCT_SUB: // sub
                        alu_control = `ALU_CTRL_SUB;
                    `FUNCT_AND: // and
                        alu_control = `ALU_CTRL_AND;
                    `FUNCT_OR: // or
                        alu_control = `ALU_CTRL_OR;
                    default: begin
                        if(^funct !== 1'bX)
                            undefined_instr = 1'b1;
                    end
                endcase
            end
            default: begin
            end
        endcase
    end   
endmodule
