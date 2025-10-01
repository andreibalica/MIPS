`timescale 1ns / 1ps

module sc_shift_left_2 #(parameter IN = 32, parameter OUT = 32)(
    input  logic [IN-1:0] in,
    output logic [OUT-1:0] out
    );
    
    assign out = in << 2;
    
endmodule
