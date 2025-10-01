import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_golden_model extends uvm_object;
    `uvm_object_utils(mips_golden_model)

    logic [31:0] registers [0:31];
    logic [31:0] memory [0:1023];

    int max_instructions_per_program = 25;

    function new(string name = "mips_golden_model");
        super.new(name);
    endfunction

    function void execute_from_file(string filename);
        logic [31:0] rom [0:1023];
        int pc = 0;
        int instructions_executed = 0;
        for (int i = 0; i < 32; i++) registers[i] = 32'h0;
        for (int i = 0; i < 1024; i++) memory[i] = 32'h0;
        
        $readmemh(filename, rom);

        while (!($isunknown(rom[pc]) || instructions_executed >= max_instructions_per_program)) begin
            execute_machine_instruction(rom[pc], pc);
            instructions_executed++;
        end
        
    endfunction

    function void execute_machine_instruction(logic [31:0] instr, ref int pc);
        logic [5:0] opcode = instr[31:26];
        logic [4:0] rs = instr[25:21];
        logic [4:0] rt = instr[20:16]; 
        logic [4:0] rd = instr[15:11];
        logic [5:0] funct = instr[5:0];
        logic [15:0] imm = instr[15:0];
        logic [25:0] addr = instr[25:0];
        int offset, target_addr;
        
        case(opcode)
            `OPCODE_RTYPE: begin
                case(funct)
                    `FUNCT_ADD: if (rd != 0) registers[rd] = registers[rs] + registers[rt];
                    `FUNCT_SUB: if (rd != 0) registers[rd] = registers[rs] - registers[rt];
                    `FUNCT_AND: if (rd != 0) registers[rd] = registers[rs] & registers[rt];
                    `FUNCT_OR:  if (rd != 0) registers[rd] = registers[rs] | registers[rt];
                endcase
            end
            
            `OPCODE_ADDI: if (rt != 0) registers[rt] = registers[rs] + $signed(imm);
            
            `OPCODE_LW: begin
                offset = registers[rs] + $signed(imm);
                if (offset >= 0 && offset < 4096) begin
                    if (rt != 0) registers[rt] = memory[offset >> 2];
                end
            end
            
            `OPCODE_SW: begin
                offset = registers[rs] + $signed(imm);
                if (offset >= 0 && offset < 4096) begin
                    memory[offset >> 2] = registers[rt];
                end
            end
            
            `OPCODE_BEQ: begin
                if (registers[rs] == registers[rt]) begin
                    target_addr = pc + 1 + $signed(imm);
                    if (target_addr >= 0) pc = target_addr;
                    return;
                end
            end
            
            `OPCODE_BNE: begin
                if (registers[rs] != registers[rt]) begin
                    target_addr = pc + 1 + $signed(imm);
                    if (target_addr >= 0) pc = target_addr;
                    return;
                end
            end
            
            `OPCODE_J: begin
                target_addr = addr;
                if (target_addr >= 0) pc = target_addr;
                return;
            end
        endcase
        pc++;
    endfunction

endclass
