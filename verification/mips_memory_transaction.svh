import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_memory_transaction extends uvm_sequence_item;
    `uvm_object_utils_begin(mips_memory_transaction)
        `uvm_field_array_int(memory, UVM_DEFAULT)
    `uvm_object_utils_end

    bit [31:0] memory[];

    function new(string name = "mips_memory_transaction");
        super.new(name);
    endfunction

endclass
