`timescale 1ns / 1ps

interface mips_interface;
    
    logic clk = 0;
    logic reset = 0;
    logic enable = 1;
    
    logic [31:0] instr;
    logic        pc_src;
    logic [31:0] pc_current;
    logic [31:0] ram [0:1023];
    logic        undefined_instr;
    logic        overflow;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

endinterface
