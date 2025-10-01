`timescale 1ns / 1ps

module pl_pipe_reg #(type T = logic [31:0]) (
    input  T     in,
    input  logic clk, 
    input  logic reset, 
    input  logic enable,
    input  logic flush,
    output T     out
);

  always_ff @(posedge clk) begin
    if (reset || flush)
      out <= '0;
    else if (enable)
      out <= in;
  end

endmodule