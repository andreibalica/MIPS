import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_sequence_random extends uvm_sequence #(mips_program_transaction);
    `uvm_object_utils(mips_sequence_random)

    rand int num_instructions;
    constraint reasonable_count { num_instructions inside {[8:15]}; }

    function new(string name = "mips_sequence_random");
        super.new(name);
    endfunction

    task body();
        mips_program_transaction packet;
        logic [31:0] machine_code;
        mips_instruction_generator instr_gen = new();

        packet = mips_program_transaction::type_id::create("mips_program");
        packet.instructions = new[num_instructions];

        for (int instr = 0; instr < num_instructions; instr++) begin
            machine_code = instr_gen.generate_random_machine_code(num_instructions);
            packet.instructions[instr] = machine_code;
        end

        start_item(packet);
        finish_item(packet);
    endtask

endclass