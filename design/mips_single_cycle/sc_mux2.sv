`timescale 1ns / 1ps

module sc_mux2 #(parameter N = 32)(
    input  logic [N-1:0] a, b,
    input  logic        sel,
    output logic [N-1:0] out
    );
    
    assign out = (sel == 0) ? a :
                 (sel == 1) ? b : 32'hx;
endmodule
