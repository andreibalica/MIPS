import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_agent extends uvm_agent;
    `uvm_component_utils(mips_agent)

    mips_driver    driver;
    mips_sequencer  sequencer;
    mips_monitor   monitor;

    function new(string name = "mips_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = mips_driver::type_id::create("driver", this);
        sequencer = mips_sequencer::type_id::create("sequencer", this);
        monitor = mips_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
