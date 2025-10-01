import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_test_random extends uvm_test;
    `uvm_component_utils(mips_test_random)

    mips_env env;

    function new(string name = "mips_test_random", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mips_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        mips_sequence_random seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        
        repeat(10) begin

            seq = mips_sequence_random::type_id::create("seq");
            void'(seq.randomize());
            seq.start(env.agent.sequencer);
            
            #50ns;
        end
        
        phase.drop_objection(this);
    endtask
    
endclass