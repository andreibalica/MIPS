import uvm_pkg::*;
`include "uvm_macros.svh"
`include "mips_defines.svh"

class mips_parser extends uvm_object;
    `uvm_object_utils(mips_parser)

    function string get_register_name(int reg_num);
        case(reg_num)
            0: return "$zero";  1: return "$at";   2: return "$v0";   3: return "$v1";
            4: return "$a0";    5: return "$a1";   6: return "$a2";   7: return "$a3";
            8: return "$t0";    9: return "$t1";   10: return "$t2";  11: return "$t3";
            12: return "$t4";   13: return "$t5";  14: return "$t6";  15: return "$t7";
            16: return "$s0";   17: return "$s1";  18: return "$s2";  19: return "$s3";
            20: return "$s4";   21: return "$s5";  22: return "$s6";  23: return "$s7";
            24: return "$t8";   25: return "$t9";  26: return "$k0";  27: return "$k1";
            28: return "$gp";   29: return "$sp";  30: return "$fp";  31: return "$ra";
            default: return "$zero";
        endcase
    endfunction

    function new(string name = "mips_parser");
        super.new(name);
    endfunction

    function string decode_machine_code(logic [31:0] machine_code);
        logic [5:0] opcode = machine_code[31:26];
        logic [4:0] rs = machine_code[25:21];
        logic [4:0] rt = machine_code[20:16]; 
        logic [4:0] rd = machine_code[15:11];
        logic [5:0] funct = machine_code[5:0];
        logic [15:0] imm = machine_code[15:0];
        logic [25:0] addr = machine_code[25:0];
        string result;
        
        case(opcode)
            `OPCODE_RTYPE: begin
                case(funct)
                    `FUNCT_ADD: result = $sformatf("add %s, %s, %s", 
                                get_register_name(rd), get_register_name(rs), get_register_name(rt));
                    `FUNCT_SUB: result = $sformatf("sub %s, %s, %s", 
                                get_register_name(rd), get_register_name(rs), get_register_name(rt));
                    `FUNCT_AND: result = $sformatf("and %s, %s, %s", 
                                get_register_name(rd), get_register_name(rs), get_register_name(rt));
                    `FUNCT_OR: result = $sformatf("or %s, %s, %s", 
                                get_register_name(rd), get_register_name(rs), get_register_name(rt));
                    default: result = $sformatf("unknown_rtype [0x%08h]", machine_code);
                endcase
            end
            `OPCODE_ADDI: result = $sformatf("addi %s, %s, %0d", 
                        get_register_name(rt), get_register_name(rs), $signed(imm));
            `OPCODE_LW: result = $sformatf("lw %s, %0d(%s)", 
                        get_register_name(rt), $signed(imm), get_register_name(rs));
            `OPCODE_SW: result = $sformatf("sw %s, %0d(%s)", 
                        get_register_name(rt), $signed(imm), get_register_name(rs));
            `OPCODE_BEQ: result = $sformatf("beq %s, %s, %0d", 
                        get_register_name(rs), get_register_name(rt), $signed(imm));
            `OPCODE_BNE: result = $sformatf("bne %s, %s, %0d", 
                        get_register_name(rs), get_register_name(rt), $signed(imm));
            `OPCODE_J: result = $sformatf("j %0d", addr);
            default: result = $sformatf("unknown [0x%08h]", machine_code);
        endcase
        
        return result;
    endfunction

endclass