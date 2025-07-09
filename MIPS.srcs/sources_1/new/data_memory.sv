`timescale 1ns / 1ps

module data_memory(
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
    );
    
    logic [31:0] ram [0:1023];
    
    initial begin
        for (int i = 0; i < 1024; i = i + 1) begin
            ram[i] = 32'd0;
        end
    end

    assign read_data = (mem_read) ? ram[address[31:2]] : 32'bz;

    always_ff @(posedge clk) begin
        if (mem_write) begin
            ram[address[31:2]] <= write_data;
        end
    end

endmodule
