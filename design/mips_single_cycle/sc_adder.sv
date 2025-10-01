`timescale 1ns / 1ps

module sc_adder(
    input  logic [31:0] op1,
    input  logic [31:0] op2,
    output logic [31:0] sum
    );
    
    assign sum = op1 + op2;
    
endmodule
