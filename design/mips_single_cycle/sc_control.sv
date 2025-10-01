`timescale 1ns / 1ps
`include "sc_mips_defines.svh"

module sc_control(
    input  logic [5:0] opcode,
    output logic       jump,
    output logic       branch_eq,
    output logic       branch_ne,
    output logic       alu_src,
    output logic       mem_write,
    output logic       mem_read,
    output logic [1:0] alu_op,
    output logic       mem_to_reg,
    output logic       reg_write,
    output logic       reg_dst,
    output logic       undefined_instr
    );
    
    always_comb begin
        jump = 1'b0;
        branch_eq = 1'b0;
        branch_ne = 1'b0;
        alu_src = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        alu_op = 2'bXX;
        mem_to_reg = 1'b0;
        reg_write = 1'b0;
        reg_dst = 1'b0;
        undefined_instr = 1'b0;

        case(opcode)
            // Type R
            `OPCODE_RTYPE: begin
                reg_dst   = 1'b1;
                reg_write = 1'b1;
                alu_op    = `ALU_OP_RTYPE;
            end
            
            // Load
            `OPCODE_LW: begin
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_op     = `ALU_OP_LW_SW;
            end
            
            // Store
            `OPCODE_SW: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = `ALU_OP_LW_SW;
            end
            
            // Add Immediate
            `OPCODE_ADDI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = `ALU_OP_LW_SW;
            end
            
            // Branch when Equal
            `OPCODE_BEQ: begin
                branch_eq = 1'b1;
                alu_op = `ALU_OP_BRANCH;
            end
            
            // Branch when Not Equal
            `OPCODE_BNE: begin
                branch_ne = 1'b1;
                alu_op = `ALU_OP_BRANCH;
            end
            
            // Jump
            `OPCODE_J : begin
                jump = 1'b1;
            end
            
            default:begin
                if(^opcode !== 1'bX)
                    undefined_instr = 1'b1;
            end
        endcase
    end
endmodule
