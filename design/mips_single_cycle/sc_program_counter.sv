`timescale 1ns / 1ps

module sc_program_counter(
    input  logic [31:0] in,
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    output logic [31:0] out
    );
    
    always_ff @(posedge clk) begin
        if(reset) begin
            out <= 32'd0;
        end
        else if (enable) begin
            out <= in;
        end
    end
         
endmodule
