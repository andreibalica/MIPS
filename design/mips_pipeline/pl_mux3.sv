`timescale 1ns / 1ps

module pl_mux3 (
    input logic [31:0] a, b, c,
    input logic [1:0] sel,
    output logic [31:0] out
);
    assign out = (sel == 2'b00) ? a :
                 (sel == 2'b01) ? b :
                 (sel == 2'b10) ? c : 32'hx;

endmodule