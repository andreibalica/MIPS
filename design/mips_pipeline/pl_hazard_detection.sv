`timescale 1ns / 1ps

module pl_hazard_detection(
   input logic [31:0] instr,
   input logic        ID_EX_mem_read,
   input logic [4:0]  ID_EX_rt,
   output logic       nop,
   output logic       pc_write,
   output logic       IF_ID_write
);

    always_comb begin
       if(ID_EX_mem_read && (ID_EX_rt == instr[25:21] || ID_EX_rt == instr[20:16])) begin
           nop = 1'b1;
           pc_write = 1'b0;
           IF_ID_write = 1'b0;
       end else begin
           nop = 1'b0;
           pc_write = 1'b1;
           IF_ID_write = 1'b1;
       end
    end
    
endmodule