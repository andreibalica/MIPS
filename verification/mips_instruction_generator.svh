import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_instruction_generator extends uvm_object;
    `uvm_object_utils(mips_instruction_generator)

    typedef enum {
        INSTR_ADD, INSTR_SUB, INSTR_AND, INSTR_OR,
        INSTR_ADDI, INSTR_LW, INSTR_SW, 
        INSTR_BEQ, INSTR_BNE, INSTR_J
    } instr_type_e;

    parameter int REG_INC_PROB = 5;
    parameter int INSTR_DEC_PROB = 3;
    parameter int TOTAL_PROB = 100;
    parameter int NR_REGISTERS = 32;
    parameter int NR_INSTRUCTIONS = 10;

    int register_probability[NR_REGISTERS];
    int instruction_probability[NR_INSTRUCTIONS];
    
    function new(string name = "mips_instruction_generator");
        super.new(name);
        for (int i = 0; i < NR_REGISTERS; i++) begin
            register_probability[i] = TOTAL_PROB / NR_REGISTERS;
        end
        for (int i = 0; i < NR_INSTRUCTIONS; i++) begin
            instruction_probability[i] = TOTAL_PROB / NR_INSTRUCTIONS;
        end
    endfunction

    function int get_register();
        int rand_val, cumulative_prob = 0;
        int reg_decrease;

        rand_val = $urandom_range(1, TOTAL_PROB);

        for (int i = 0; i < NR_REGISTERS; i++) begin
            cumulative_prob += register_probability[i];
            if (rand_val <= cumulative_prob) begin
                register_probability[i] = register_probability[i] + REG_INC_PROB;

                reg_decrease = REG_INC_PROB / (NR_REGISTERS - 1);
                for (int j = 0; j < NR_REGISTERS; j++) begin
                    if (j != i) begin
                        register_probability[j] = register_probability[j] - reg_decrease;
                    end
                end
                
                return i;
            end
        end
    endfunction

    function instr_type_e get_instruction();
        int rand_val, cumulative_prob = 0;
        int instr_increase;

        rand_val = $urandom_range(1, TOTAL_PROB);

        for (int i = 0; i < NR_INSTRUCTIONS; i++) begin
            cumulative_prob += instruction_probability[i];
            if (rand_val <= cumulative_prob) begin
                instruction_probability[i] = instruction_probability[i] - INSTR_DEC_PROB;

                instr_increase = INSTR_DEC_PROB / (NR_INSTRUCTIONS - 1);
                for (int j = 0; j < NR_INSTRUCTIONS; j++) begin
                    if (j != i) begin
                        instruction_probability[j] = instruction_probability[j] + instr_increase;
                    end
                end
                
                return instr_type_e'(i);
            end
        end
    endfunction

    
    function logic [31:0] generate_random_machine_code(int num_instructions);
        instr_type_e instr_type;
        logic [4:0] rs, rt, rd;
        logic [15:0] immediate;
        logic [25:0] address;
        logic [31:0] machine_code;
        
        instr_type = get_instruction();

        rs = get_register();
        rt = get_register(); 
        rd = get_register();

        if (rd == 0 && (instr_type inside {INSTR_ADD, INSTR_SUB, INSTR_AND, INSTR_OR, INSTR_ADDI, INSTR_LW})) begin
            rd = get_register();
            if (rd == 0) rd = 1;
        end
        
        case(instr_type)
            INSTR_ADD: begin
                machine_code = (`OPCODE_RTYPE << 26) | (rs << 21) | (rt << 16) | (rd << 11) | `FUNCT_ADD;
            end
            
            INSTR_SUB: begin
                machine_code = (`OPCODE_RTYPE << 26) | (rs << 21) | (rt << 16) | (rd << 11) | `FUNCT_SUB;
            end
            
            INSTR_AND: begin
                machine_code = (`OPCODE_RTYPE << 26) | (rs << 21) | (rt << 16) | (rd << 11) | `FUNCT_AND;
            end
            
            INSTR_OR: begin
                machine_code = (`OPCODE_RTYPE << 26) | (rs << 21) | (rt << 16) | (rd << 11) | `FUNCT_OR;
            end
            
            INSTR_ADDI: begin
                immediate = $urandom_range(-100, 100);
                machine_code = (`OPCODE_ADDI << 26) | (rs << 21) | (rt << 16) | immediate;
            end
            
            INSTR_LW: begin
                immediate = $urandom_range(0, 255) << 2;
                machine_code = (`OPCODE_LW << 26) | (rs << 21) | (rt << 16) | immediate;
            end
            
            INSTR_SW: begin
                immediate = $urandom_range(0, 255) << 2;
                machine_code = (`OPCODE_SW << 26) | (rs << 21) | (rt << 16) | immediate;
            end
            
            INSTR_BEQ: begin
                immediate = $urandom_range(-4, 4);
                machine_code = (`OPCODE_BEQ << 26) | (rs << 21) | (rt << 16) | immediate;
            end
            
            INSTR_BNE: begin
                immediate = $urandom_range(-4, 4);
                machine_code = (`OPCODE_BNE << 26) | (rs << 21) | (rt << 16) | immediate;
            end
            
            INSTR_J: begin
                address = $urandom_range(0, num_instructions);
                machine_code = (`OPCODE_J << 26) | address;
            end
            
            default: begin
                machine_code = 32'h00000000;
            end
        endcase
        
        return machine_code;
    endfunction

endclass