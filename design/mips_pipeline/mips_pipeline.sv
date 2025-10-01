`timescale 1ns / 1ps
`include "pl_mips_defines.svh"

module mips_pipeline(
    input logic clk,
    input logic reset,
    input logic enable
    );

    typedef struct packed {
        logic [31:0] pc_current;
        logic [31:0] pc_plus_4;
        logic [31:0] instr;
        logic        predicted_taken;
        logic [31:0] predicted_target;
    } IF_ID_t;

    typedef struct packed {
        logic [31:0] pc_current;
        logic [31:0] pc_plus_4;
        logic [31:0] instr;
        logic [31:0] reg_file_read_data;
        logic [31:0] instr_extend;
        logic [27:0] instr_shift;
        logic [31:0] alu_op1;
        logic [3:0]  alu_control_input;
        logic        alu_src;
        logic        mem_read;
        logic        mem_write;
        logic        mem_to_reg;
        logic        reg_write;
        logic        reg_dst;
        logic        branch_eq;
        logic        branch_ne;
        logic        jump;
        logic        control_undefined_instr;
        logic        predicted_taken;
        logic [31:0] predicted_target;
    } ID_EX_t;

    typedef struct packed {
        logic [31:0] pc_current;
        logic [31:0] pc_plus_4;
        logic [31:0] branch_target_address;
        logic [31:0] alu_res;
        logic [31:0] reg_file_read_data;
        logic [4:0]  write_reg;
        logic        zero;
        logic        branch_eq;
        logic        branch_ne;
        logic        jump;
        logic        mem_read;
        logic        mem_write;
        logic        mem_to_reg;
        logic        reg_write;
        logic        control_undefined_instr;
        logic        alu_control_undefined_instr;
        logic        overflow;
        logic        predicted_taken;
        logic [31:0] predicted_target;
    } EX_MEM_t;

    typedef struct packed {
        logic [31:0] pc_current;
        logic [31:0] alu_res;
        logic [31:0] data_memory_read_data;
        logic [4:0]  write_reg;
        logic        mem_to_reg;
        logic        reg_write;
        logic        control_undefined_instr;
        logic        alu_control_undefined_instr;
        logic        overflow;
    } MEM_WB_t;
    
    IF_ID_t IF_ID_in, IF_ID_out;
    ID_EX_t ID_EX_in, ID_EX_out;
    EX_MEM_t EX_MEM_in, EX_MEM_out;
    MEM_WB_t MEM_WB_in, MEM_WB_out;
    
    logic [31:0] pc_next;
    logic [31:0] instr_extend_shift;
    logic [31:0] write_data;
    logic [31:0] alu_op1;
    logic [31:0] alu_op2;
    logic [31:0] branch_or_plus4_address;
    logic [31:0] branch_or_plus4_address_or_jump;
    logic [1:0]  control_alu_op;
    logic        pc_src;
    logic        branch_flush;
    logic        nop;
    logic        pc_write;
    logic        IF_ID_write;
    logic        reg_write;
    logic        control_undefined_instr;
    logic        alu_control_undefined_instr;
    logic        undefined_instr;
    logic        overflow;

    logic [31:0] epc_reg; 
    logic        write_epc;
    
    logic [31:0] exception_vector;

    logic [31:0] predicted_branch_target;
    logic [31:0] branch_predicted_address;
    logic [31:0] branch_correction_address;
    logic        predicted_taken;
    logic        branch_taken_actual;
    logic        branch_mispredicted;
    logic        is_branch_instruction;


    // === IF (Instruction Fetch) ===

    pl_branch_prediction bp_inst(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .is_branch_instruction(is_branch_instruction),
        .branch_taken_actual(branch_taken_actual),
        .predicted_taken(predicted_taken)
    );

    pl_program_counter pc_inst(
        .in(pc_next),
        .clk(clk),
        .reset(reset),
        .enable(enable && pc_write),
        .out(IF_ID_in.pc_current)
    );

    pl_adder adder_pc(
        .op1(32'd4),
        .op2(IF_ID_in.pc_current),
        .sum(IF_ID_in.pc_plus_4)
    );

    pl_instruction_memory instruction_memory_inst(
        .clk(clk),
        .reset(reset),
        .address(IF_ID_in.pc_current),
        .instruction(IF_ID_in.instr)
    );

    logic [31:0] if_branch_target;
    logic [31:0] if_branch_target_shifted;
    logic        if_is_branch;

    pl_sign_extend sign_extend_if_branch_target(
        .in(IF_ID_in.instr[15:0]),
        .out(if_branch_target)
    );

    pl_shift_left_2 shift_left_2_if_branch_target(
        .in(if_branch_target),
        .out(if_branch_target_shifted)
    );

    pl_adder adder_if_branch(
        .op1(IF_ID_in.pc_plus_4),
        .op2(if_branch_target_shifted),
        .sum(predicted_branch_target)
    );

    assign if_is_branch = (IF_ID_in.instr[31:26] == `OPCODE_BEQ) || (IF_ID_in.instr[31:26] == `OPCODE_BNE);

    assign IF_ID_in.predicted_taken = predicted_taken && if_is_branch;
    assign IF_ID_in.predicted_target = predicted_branch_target;

    pl_mux2 mux2_pc_prediction(
        .a(IF_ID_in.pc_plus_4),
        .b(IF_ID_in.predicted_target),
        .sel(IF_ID_in.predicted_taken),
        .out(branch_predicted_address)
    );

    assign branch_correction_address = EX_MEM_out.predicted_taken ? EX_MEM_out.pc_plus_4 : EX_MEM_out.branch_target_address;

    pl_mux2 mux2_pc_correction(
        .a(branch_predicted_address),
        .b(branch_correction_address),
        .sel(branch_mispredicted),
        .out(branch_or_plus4_address)
    );

    pl_mux2 mux2_jump(
        .a(branch_or_plus4_address),
        .b({IF_ID_in.pc_plus_4[31:28], ID_EX_in.instr_shift}),
        .sel(ID_EX_in.jump),
        .out(branch_or_plus4_address_or_jump)
    );

    pl_mux2 mux2_exception(
        .a(branch_or_plus4_address_or_jump),
        .b(exception_vector),
        .sel(undefined_instr || MEM_WB_out.overflow),
        .out(pc_next)
    );
    
    // === IF (Instruction Fetch) -> ID (Instruction Decode) ===

    pl_pipe_reg #(.T(IF_ID_t)) reg_IF_ID (
        .in(IF_ID_in),
        .clk(clk),
        .reset(reset),
        .enable(enable && IF_ID_write),
        .flush(branch_flush),
        .out(IF_ID_out)
    );
    
    // === ID (Instruction Decode) ===

    pl_hazard_detection hazard_detection_inst(
        .instr(IF_ID_out.instr),
        .ID_EX_mem_read(ID_EX_out.mem_read),
        .ID_EX_rt(ID_EX_out.instr[20:16]),
        .nop(nop),
        .pc_write(pc_write),
        .IF_ID_write(IF_ID_write)
    );

    pl_control control_inst(
        .opcode(IF_ID_out.instr[31:26]),
        .nop(nop),
        .jump(ID_EX_in.jump),
        .branch_eq(ID_EX_in.branch_eq),
        .branch_ne(ID_EX_in.branch_ne),
        .alu_src(ID_EX_in.alu_src),
        .mem_write(ID_EX_in.mem_write),
        .mem_read(ID_EX_in.mem_read),
        .alu_op(control_alu_op),
        .mem_to_reg(ID_EX_in.mem_to_reg),
        .reg_write(ID_EX_in.reg_write),
        .reg_dst(ID_EX_in.reg_dst),
        .undefined_instr(control_undefined_instr)
    );

    pl_alu_control alu_control_inst(
        .funct(IF_ID_out.instr[5:0]),
        .alu_op(control_alu_op),
        .alu_control(ID_EX_in.alu_control_input),
        .undefined_instr(alu_control_undefined_instr)
    );

    pl_reg_file reg_file_inst(
        .read_reg_1(IF_ID_out.instr[25:21]),
        .read_reg_2(IF_ID_out.instr[20:16]),
        .write_reg(MEM_WB_out.write_reg),
        .write_data(write_data),
        .reg_write(MEM_WB_out.reg_write),
        .clk(clk),
        .enable(enable),
        .read_data_1(ID_EX_in.alu_op1),
        .read_data_2(ID_EX_in.reg_file_read_data)
    );

    pl_sign_extend sign_extend_inst(
        .in(IF_ID_out.instr[15:0]),
        .out(ID_EX_in.instr_extend)
    );

    pl_shift_left_2 #(.IN(26), .OUT(28)) shift_instr(
        .in(IF_ID_out.instr[25:0]),
        .out(ID_EX_in.instr_shift)
    );
    
    assign ID_EX_in.pc_current = IF_ID_out.pc_current;
    assign ID_EX_in.pc_plus_4 = IF_ID_out.pc_plus_4;
    assign ID_EX_in.instr = IF_ID_out.instr;
    assign ID_EX_in.control_undefined_instr = control_undefined_instr;
    assign ID_EX_in.predicted_taken = IF_ID_out.predicted_taken;
    assign ID_EX_in.predicted_target = IF_ID_out.predicted_target;
    
    // === ID (Instruction Decode) -> EX (Execute) ===

    pl_pipe_reg #(.T(ID_EX_t)) reg_ID_EX (
        .in(ID_EX_in),
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .flush(branch_flush),
        .out(ID_EX_out)
    );
    
    // === EX (Execute) ===

    logic [1:0] forward_a, forward_b, forward_store_data;
    logic [31:0] alu_op2_src;

    pl_forwarding_control forwarding_control_inst(
        .ID_EX_rs(ID_EX_out.instr[25:21]),
        .ID_EX_rt(ID_EX_out.instr[20:16]),
        .EX_MEM_rd(EX_MEM_out.write_reg),
        .MEM_WB_rd(MEM_WB_out.write_reg),
        .EX_MEM_reg_write(EX_MEM_out.reg_write),
        .MEM_WB_reg_write(MEM_WB_out.reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .forward_store_data(forward_store_data)
    );

    pl_mux3 mux3_forward_a(
        .a(ID_EX_out.alu_op1),
        .b(write_data),
        .c(EX_MEM_out.alu_res),
        .sel(forward_a),
        .out(alu_op1)
    );

    pl_mux3 mux3_forward_b(
        .a(ID_EX_out.reg_file_read_data),
        .b(write_data),
        .c(EX_MEM_out.alu_res),
        .sel(forward_b),
        .out(alu_op2)
    );

    pl_mux3 mux3_forward_store_data(
        .a(ID_EX_out.reg_file_read_data),
        .b(write_data),
        .c(EX_MEM_out.alu_res),
        .sel(forward_store_data),
        .out(EX_MEM_in.reg_file_read_data)
    );

    pl_shift_left_2 shift_instr_extend(
        .in(ID_EX_out.instr_extend),
        .out(instr_extend_shift)
    );

    pl_adder adder_branch_address(
        .op1(ID_EX_out.pc_plus_4),
        .op2(instr_extend_shift),
        .sum(EX_MEM_in.branch_target_address)
    );

    pl_mux2 #(5) mux2_reg_dst(
        .a(ID_EX_out.instr[20:16]),
        .b(ID_EX_out.instr[15:11]),
        .sel(ID_EX_out.reg_dst),
        .out(EX_MEM_in.write_reg)
    );

    pl_mux2 mux2_alu_src(
        .a(alu_op2),
        .b(ID_EX_out.instr_extend),
        .sel(ID_EX_out.alu_src),
        .out(alu_op2_src)
    );

    pl_alu alu_inst(
        .op1(alu_op1),
        .op2(alu_op2_src),
        .alu_control(ID_EX_out.alu_control_input),
        .res(EX_MEM_in.alu_res),
        .zero(EX_MEM_in.zero),
        .overflow(EX_MEM_in.overflow)
    );
    
    assign EX_MEM_in.pc_current = ID_EX_out.pc_current;
    assign EX_MEM_in.pc_plus_4 = ID_EX_out.pc_plus_4;
    assign EX_MEM_in.branch_eq = ID_EX_out.branch_eq;
    assign EX_MEM_in.branch_ne = ID_EX_out.branch_ne;
    assign EX_MEM_in.jump = ID_EX_out.jump;
    assign EX_MEM_in.mem_read = ID_EX_out.mem_read;
    assign EX_MEM_in.mem_write = ID_EX_out.mem_write;
    assign EX_MEM_in.mem_to_reg = ID_EX_out.mem_to_reg;
    assign EX_MEM_in.reg_write = ID_EX_out.reg_write;
    assign EX_MEM_in.control_undefined_instr = ID_EX_out.control_undefined_instr;
    assign EX_MEM_in.alu_control_undefined_instr = alu_control_undefined_instr;
    assign EX_MEM_in.predicted_taken = ID_EX_out.predicted_taken;
    assign EX_MEM_in.predicted_target = ID_EX_out.predicted_target;
    
    // === EX (Execute) -> MEM (Memory Access) ===

    pl_pipe_reg #(.T(EX_MEM_t)) reg_EX_MEM (
        .in(EX_MEM_in),
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .flush(branch_flush),
        .out(EX_MEM_out)
    );
    
    // === MEM (Memory Access) ===

    pl_data_memory data_memory_inst(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .mem_read(EX_MEM_out.mem_read),
        .mem_write(EX_MEM_out.mem_write),
        .address(EX_MEM_out.alu_res),
        .write_data(EX_MEM_out.reg_file_read_data),
        .read_data(MEM_WB_in.data_memory_read_data)
    );

    pl_branch_control branch_control_inst(
        .zero(EX_MEM_out.zero),
        .branch_eq(EX_MEM_out.branch_eq),
        .branch_ne(EX_MEM_out.branch_ne),
        .pc_src(pc_src)
    );

    assign is_branch_instruction = EX_MEM_out.branch_eq || EX_MEM_out.branch_ne;
    assign branch_taken_actual = pc_src && is_branch_instruction;

    assign branch_mispredicted = is_branch_instruction && ((EX_MEM_out.predicted_taken && !pc_src) || (!EX_MEM_out.predicted_taken && pc_src)); 

    assign branch_flush = branch_mispredicted;
    assign MEM_WB_in.pc_current = EX_MEM_out.pc_current;
    assign MEM_WB_in.alu_res = EX_MEM_out.alu_res;
    assign MEM_WB_in.write_reg = EX_MEM_out.write_reg;
    assign MEM_WB_in.mem_to_reg = EX_MEM_out.mem_to_reg;
    assign MEM_WB_in.reg_write = EX_MEM_out.reg_write;
    assign MEM_WB_in.control_undefined_instr = EX_MEM_out.control_undefined_instr;
    assign MEM_WB_in.alu_control_undefined_instr = EX_MEM_out.alu_control_undefined_instr;
    assign MEM_WB_in.overflow = EX_MEM_out.overflow;
    
    // === MEM (Memory Access) -> WB (Write Back) ===

    pl_pipe_reg #(.T(MEM_WB_t)) reg_MEM_WB (
        .in(MEM_WB_in),
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .flush(1'b0),
        .out(MEM_WB_out)
    );
    
    // === WB (Write Back) ===

    pl_mux2 mux2_mem_to_reg(
        .a(MEM_WB_out.alu_res),
        .b(MEM_WB_out.data_memory_read_data),
        .sel(MEM_WB_out.mem_to_reg),
        .out(write_data)
    );

    pl_exception_control exception_control_inst(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .control_undefined_instr(MEM_WB_out.control_undefined_instr),
        .alu_control_undefined_instr(MEM_WB_out.alu_control_undefined_instr),
        .overflow(MEM_WB_out.overflow),
        .pc_current(MEM_WB_out.pc_current),
        .undefined_instr(undefined_instr),
        .exception_vector(exception_vector),
        .write_epc(write_epc),
        .epc_reg(epc_reg)
    );
    
endmodule