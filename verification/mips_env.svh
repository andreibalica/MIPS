import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_env extends uvm_env;
    `uvm_component_utils(mips_env)

    mips_agent    agent;
    mips_coverage  coverage;
    mips_scoreboard scoreboard;

    function new(string name = "mips_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent     = mips_agent::type_id::create("agent", this);
        coverage  = mips_coverage::type_id::create("coverage", this);
        scoreboard = mips_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.instr_inport.connect(coverage.analysis_export);
        agent.monitor.memory_inport.connect(scoreboard.memory_export);
    endfunction
endclass