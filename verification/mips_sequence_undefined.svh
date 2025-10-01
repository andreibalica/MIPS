import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_sequence_undefined extends uvm_sequence #(mips_program_transaction);
    `uvm_object_utils(mips_sequence_undefined)

    function new(string name = "mips_sequence_undefined");
        super.new(name);
    endfunction

    task body();
        mips_program_transaction opcode_inv_packet;
        mips_program_transaction funct_inv_packet;
        
        opcode_inv_packet = mips_program_transaction::type_id::create("opcode_invalid_program");
        opcode_inv_packet.instructions = new[1];

        opcode_inv_packet.instructions[0] = {`OPCODE_INV, 5'd8, 5'd9, 5'd10, 5'b00000, `FUNCT_ADD};

        start_item(opcode_inv_packet);
        finish_item(opcode_inv_packet);

        funct_inv_packet = mips_program_transaction::type_id::create("funct_invalid_program");
        funct_inv_packet.instructions = new[1];

        funct_inv_packet.instructions[0] = {`OPCODE_RTYPE, 5'd8, 5'd9, 5'd10, 5'b00000, `FUNCT_INV};

        start_item(funct_inv_packet);
        finish_item(funct_inv_packet);

    endtask

endclass