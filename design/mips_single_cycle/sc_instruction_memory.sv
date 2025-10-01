`timescale 1ns / 1ps
`include "sc_mips_defines.svh"

module sc_instruction_memory(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] address,
    output logic [31:0] instruction
    );
    
    logic [31:0] rom [0:1023];
    
    initial begin
        $readmemh("instructions.mem", rom);
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            $readmemh("instructions.mem", rom);
        end
    end
    
    always_comb begin
        if (address == `UNDEFINED_HANDLER_ADDR) begin
            instruction = `EXCEPTION_LOOP_UNDEF;
        end else if (address == `OVERFLOW_HANDLER_ADDR) begin
            instruction = `EXCEPTION_LOOP_OVERFLOW;
        end else begin
            instruction = rom[address[31:2]];
        end
    end
    
endmodule
