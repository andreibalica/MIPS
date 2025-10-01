import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_instruction_transaction extends uvm_sequence_item;

    `uvm_object_utils_begin(mips_instruction_transaction)
        `uvm_field_int(instr, UVM_DEFAULT)
        `uvm_field_int(pc_src, UVM_DEFAULT)
    `uvm_object_utils_end
    
    logic [31:0] instr;
    bit pc_src;

    function new(string name = "mips_instruction_transaction");
        super.new(name);
    endfunction
endclass
