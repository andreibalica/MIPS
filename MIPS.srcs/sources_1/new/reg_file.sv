`timescale 1ns / 1ps

module reg_file(
    input  logic [4:0]  read_reg_1,
    input  logic [4:0]  read_reg_2,
    input  logic [4:0]  write_reg,
    input  logic [31:0] write_data,
    input  logic        reg_write,
    input  logic        clk,
    output logic [31:0] read_data_1,
    output logic [31:0] read_data_2
    );
    
    logic [31:0] registers [0:31];
    
    initial begin
        for (int i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'd0;
        end
    end
    
    assign read_data_1 = registers[read_reg_1];
    assign read_data_2 = registers[read_reg_2];
    
    always_ff @(posedge clk) begin
        if(reg_write) begin
            if(write_reg != 5'd0) begin
                registers[write_reg] <= write_data;
            end
        end
    end
endmodule
