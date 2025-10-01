`timescale 1ns / 1ps

import uvm_pkg::*;
import mips_pkg::*;

module top_mips_pipeline;

    mips_interface mips_if();
    
    mips_pipeline dut(
        .clk(mips_if.clk),
        .reset(mips_if.reset),
        .enable(mips_if.enable)
    );

    assign mips_if.instr = dut.IF_ID_out.instr;
    assign mips_if.pc_current = dut.IF_ID_out.pc_current;
    assign mips_if.ram = dut.data_memory_inst.ram;
    assign mips_if.pc_src = dut.pc_src;
    assign mips_if.undefined_instr = dut.undefined_instr;
    assign mips_if.overflow = dut.EX_MEM_in.overflow;

    initial begin
        uvm_config_db#(virtual mips_interface)::set(null, "*", "mips_vif", mips_if);
        uvm_config_db#(int)::set(null, "*", "verbosity", UVM_HIGH);

        run_test("mips_test_random");
    end

endmodule