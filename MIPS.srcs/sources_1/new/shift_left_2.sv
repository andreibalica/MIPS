`timescale 1ns / 1ps

module shift_left_2 #(parameter N = 32)(
    input  logic [N-1:0] in,
    output logic [N-1:0] out
    );
    
    assign out = in << 2;
    
endmodule
