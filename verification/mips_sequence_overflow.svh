import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_sequence_overflow extends uvm_sequence #(mips_program_transaction);
    `uvm_object_utils(mips_sequence_overflow)

    function new(string name = "mips_sequence_overflow");
        super.new(name);
    endfunction

    task body();
        mips_program_transaction overflow_packet;
        mips_program_transaction underflow_packet;

        overflow_packet = mips_program_transaction::type_id::create("mips_program");
        overflow_packet.instructions = new[18];

        overflow_packet.instructions[0] = {`OPCODE_ADDI, 5'd0, 5'd8, 16'h7FFF};

        for (int i = 1; i < 18; i++) begin
            overflow_packet.instructions[i] = {`OPCODE_RTYPE, 5'd8, 5'd8, 5'd8, 5'b00000, `FUNCT_ADD};
        end

        start_item(overflow_packet);
        finish_item(overflow_packet);

        underflow_packet = mips_program_transaction::type_id::create("mips_program");
        
        underflow_packet.instructions = new[18];
        
        underflow_packet.instructions[0] = {`OPCODE_ADDI, 5'b00000, 5'd9, 16'h8000};
        
        for (int i = 1; i < 18; i++) begin
            underflow_packet.instructions[i] = {`OPCODE_RTYPE, 5'd9, 5'd9, 5'd9, 5'b00000, `FUNCT_ADD};
        end

        start_item(underflow_packet);
        finish_item(underflow_packet);
    endtask

endclass