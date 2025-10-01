`timescale 1ns / 1ps
`include "sc_mips_defines.svh"

module sc_exception_control(
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    input  logic        control_undefined_instr,
    input  logic        alu_control_undefined_instr,
    input  logic        overflow,
    input  logic [31:0] pc_current,
    output logic        undefined_instr,
    output logic [31:0] exception_vector,
    output logic        write_epc,
    output logic [31:0] epc_reg
);
    assign undefined_instr = control_undefined_instr | alu_control_undefined_instr;

    assign exception_vector = undefined_instr ? `UNDEFINED_HANDLER_ADDR :
                              overflow        ? `OVERFLOW_HANDLER_ADDR :
                              32'h0;

    assign write_epc = undefined_instr || overflow;

    always_ff @(posedge clk) begin
        if (reset) begin
            epc_reg <= 32'h0;
        end else if (enable && write_epc) begin
            epc_reg <= pc_current;
        end
    end
endmodule
