`timescale 1ns / 1ps

module sc_reg_file(
    input  logic [4:0]  read_reg_1,
    input  logic [4:0]  read_reg_2,
    input  logic [4:0]  write_reg,
    input  logic [31:0] write_data,
    input  logic        reg_write,
    input  logic        reset,
    input  logic        clk,
    input  logic        enable,
    output logic [31:0] read_data_1,
    output logic [31:0] read_data_2
    );
    
    logic [31:0] registers [0:31];

    always_comb begin
        read_data_1 = registers[read_reg_1];
        read_data_2 = registers[read_reg_2];
    end
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
        end else if (enable && reg_write) begin
            if (write_reg != 5'd0)
                registers[write_reg] <= write_data;
        end
    end
endmodule
