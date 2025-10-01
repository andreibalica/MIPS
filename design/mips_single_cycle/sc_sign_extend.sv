`timescale 1ns / 1ps

module sc_sign_extend(
    input  logic [15:0] in,
    output logic [31:0] out
    );
    
    assign out = {{16{in[15]}}, in};
    
endmodule
