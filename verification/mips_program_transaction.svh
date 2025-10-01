import uvm_pkg::*;
`include "uvm_macros.svh"

class mips_program_transaction extends uvm_sequence_item;
    `uvm_object_utils_begin(mips_program_transaction)
        `uvm_field_array_int(instructions, UVM_DEFAULT)
    `uvm_object_utils_end
    
    logic [31:0] instructions[];

    function new(string name = "mips_program_transaction");
        super.new(name);
    endfunction

endclass