`timescale 1ns / 1ps

module program_counter(
    input  logic [31:0] in,
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] out
    );
    
    always_ff @(posedge clk) begin
        if(reset) begin
            out <= 32'd0;
        end
        else begin
            out <= in;
        end
    end     
endmodule
