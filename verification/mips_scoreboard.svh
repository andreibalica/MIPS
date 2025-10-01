import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mips_scoreboard)

    uvm_analysis_imp #(mips_memory_transaction, mips_scoreboard) memory_export;
    mips_golden_model golden_model;

    function new(string name = "mips_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        memory_export = new("memory_export", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        golden_model = mips_golden_model::type_id::create("golden_model");
    endfunction

    function void write(mips_memory_transaction t);

        golden_model.execute_from_file("instructions.mem");
            
        compare_memory(t);
        
    endfunction

    function void compare_memory(mips_memory_transaction t);
        int mismatches = 0;
        
        foreach (t.memory[i]) begin
            if (t.memory[i] !== golden_model.memory[i]) begin
                `uvm_error("SCOREBOARD", $sformatf("Mem[%0d] mismatch: DUT=0x%08h, GOLDEN=0x%08h", 
                          i, t.memory[i], golden_model.memory[i]))
                mismatches++;
            end
        end
    endfunction

endclass