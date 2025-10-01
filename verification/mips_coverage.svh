import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_coverage extends uvm_component;

    `uvm_component_utils(mips_coverage)
    uvm_analysis_imp #(mips_instruction_transaction, mips_coverage) analysis_export;

    logic [31:0] instr;
    logic [31:0] alu_res;
    bit pc_src;
    logic [5:0] opcode;
    logic [4:0] rs, rt, rd;
    logic [15:0] immediate;
    logic [25:0] jump_addr;
    
    covergroup instr_type_cg;
        opcode_cp: coverpoint opcode {
            bins r_type = {`OPCODE_RTYPE};
            bins addi = {`OPCODE_ADDI};
            bins lw = {`OPCODE_LW};
            bins sw = {`OPCODE_SW};
            bins beq = {`OPCODE_BEQ};
            bins bne = {`OPCODE_BNE};
            bins j = {`OPCODE_J};
        }
    endgroup

    covergroup reg_usage_cg;

        rs_cp: coverpoint rs iff (opcode == `OPCODE_RTYPE || opcode == `OPCODE_ADDI || 
                                 opcode == `OPCODE_LW || opcode == `OPCODE_SW ||
                                 opcode == `OPCODE_BEQ || opcode == `OPCODE_BNE) {
            bins zero = {0};                    // $zero
            bins at = {1};                      // $at (assembler temporary)
            bins return_vals[] = {[2:3]};       // $v0-$v1 (return values)
            bins args[] = {[4:7]};              // $a0-$a3 (arguments)
            bins temps[] = {[8:15]};            // $t0-$t7 (temporaries)
            bins saved[] = {[16:23]};           // $s0-$s7 (saved)
            bins kernel_temps[] = {[24:25]};    // $t8-$t9 (more temps)
            bins kernel[] = {[26:27]};          // $k0-$k1 (kernel reserved)
            bins gp = {28};                     // $gp (global pointer)
            bins sp = {29};                     // $sp (stack pointer)
            bins fp = {30};                     // $fp (frame pointer)
            bins ra = {31};                     // $ra (return address)
        }

        rt_cp: coverpoint rt iff (opcode == `OPCODE_RTYPE || opcode == `OPCODE_ADDI || 
                                 opcode == `OPCODE_LW || opcode == `OPCODE_SW ||
                                 opcode == `OPCODE_BEQ || opcode == `OPCODE_BNE) {
            bins zero = {0};                    // $zero
            bins at = {1};                      // $at (assembler temporary)
            bins return_vals[] = {[2:3]};       // $v0-$v1 (return values)
            bins args[] = {[4:7]};              // $a0-$a3 (arguments)
            bins temps[] = {[8:15]};            // $t0-$t7 (temporaries)
            bins saved[] = {[16:23]};           // $s0-$s7 (saved)
            bins kernel_temps[] = {[24:25]};    // $t8-$t9 (more temps)
            bins kernel[] = {[26:27]};          // $k0-$k1 (kernel reserved)
            bins gp = {28};                     // $gp (global pointer)
            bins sp = {29};                     // $sp (stack pointer)
            bins fp = {30};                     // $fp (frame pointer)
            bins ra = {31};                     // $ra (return address)
        }

        rd_cp: coverpoint rd iff (opcode == `OPCODE_RTYPE) {
            bins zero = {0};                    // $zero
            bins at = {1};                      // $at (assembler temporary)
            bins return_vals[] = {[2:3]};       // $v0-$v1 (return values)
            bins args[] = {[4:7]};              // $a0-$a3 (arguments)
            bins temps[] = {[8:15]};            // $t0-$t7 (temporaries)
            bins saved[] = {[16:23]};           // $s0-$s7 (saved)
            bins kernel_temps[] = {[24:25]};    // $t8-$t9 (more temps)
            bins kernel[] = {[26:27]};          // $k0-$k1 (kernel reserved)
            bins gp = {28};                     // $gp (global pointer)
            bins sp = {29};                     // $sp (stack pointer)
            bins fp = {30};                     // $fp (frame pointer)
            bins ra = {31};                     // $ra (return address)
        }
    endgroup

    covergroup branch_cg;
        opcode_cp: coverpoint opcode {
            bins branch_instrs[] = {`OPCODE_BEQ, `OPCODE_BNE};
        }
        branch_taken_cp: coverpoint pc_src;
        cross_cp: cross opcode_cp, branch_taken_cp;
    endgroup

    covergroup mem_access_cg;
        opcode_cp: coverpoint opcode {
            bins mem_instrs[] = {`OPCODE_LW, `OPCODE_SW};
        }
        mem_addr_cp: coverpoint alu_res[9:2] {
            bins addr_0_15[] = {[0:15]};
            bins addr_16_31[] = {[16:31]};
            bins addr_32_47[] = {[32:47]};
            bins addr_48_63[] = {[48:63]};
            bins addr_64_127[] = {[64:127]};
            bins addr_128_255[] = {[128:255]};
        }
    endgroup

    function new(string name = "mips_coverage", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        instr_type_cg = new();
        reg_usage_cg = new();
        branch_cg = new();
        mem_access_cg = new();
    endfunction

    function void write(mips_instruction_transaction t);
        instr = t.instr;
        pc_src = t.pc_src;
        opcode = instr[31:26];
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        immediate = instr[15:0];
        jump_addr = instr[25:0];
        
        instr_type_cg.sample();
        reg_usage_cg.sample();
        branch_cg.sample();
        mem_access_cg.sample();
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COVERAGE", $sformatf("Instruction Type Coverage: %.2f%%", instr_type_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Register Usage Coverage: %.2f%%", reg_usage_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Branch Coverage: %.2f%%", branch_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Memory Access Coverage: %.2f%%", mem_access_cg.get_coverage()), UVM_LOW)
    endfunction

endclass