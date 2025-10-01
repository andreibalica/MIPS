`timescale 1ns / 1ps

module pl_forwarding_control(
    input  logic [4:0] ID_EX_rs,
    input  logic [4:0] ID_EX_rt,
    input  logic [4:0] EX_MEM_rd,
    input  logic [4:0] MEM_WB_rd,
    input  logic       EX_MEM_reg_write,
    input  logic       MEM_WB_reg_write,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b,
    output logic [1:0] forward_store_data
);

    always_comb begin
        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs)) begin
            forward_a = 2'b10;
        end else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs)) begin
            forward_a = 2'b01;
        end else begin
            forward_a = 2'b00;
        end

        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rt)) begin
            forward_b = 2'b10;
        end else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rt)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
        
        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rt)) begin
            forward_store_data = 2'b10;
        end else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rt)) begin
            forward_store_data = 2'b01;
        end else begin
            forward_store_data = 2'b00;
        end
    end

endmodule