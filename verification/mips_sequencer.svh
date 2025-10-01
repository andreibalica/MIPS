import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_sequencer extends uvm_sequencer #(mips_program_transaction);
    `uvm_component_utils(mips_sequencer)

    function new(string name = "mips_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
