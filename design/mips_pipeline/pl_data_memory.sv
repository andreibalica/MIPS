`timescale 1ns / 1ps

module pl_data_memory(
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
    );
    
    logic [31:0] ram [0:1023];

    always_comb begin
        read_data = (mem_read) ? ram[address[31:2]] : 32'bx;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 1024; i = i + 1)
                ram[i] <= 32'd0;
        end else if (enable && mem_write) begin
            ram[address[31:2]] <= write_data;
        end
    end

endmodule
