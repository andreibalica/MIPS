import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_test_overflow extends uvm_test;
    `uvm_component_utils(mips_test_overflow)

    mips_env env;

    function new(string name = "mips_test_overflow", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mips_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        mips_sequence_overflow seq;
        super.run_phase(phase);
        phase.raise_objection(this);

        seq = mips_sequence_overflow::type_id::create("seq");
        seq.start(env.agent.sequencer);
            
        #50ns;
        
        phase.drop_objection(this);
    endtask
    
endclass