`timescale 1ns / 1ps

module mips(
    input logic clk,
    input logic reset
    );
    
    logic [31:0] pc_next;
    logic [31:0] pc_current;
    logic [31:0] pc_plus_4;
    logic [31:0] instr;
    logic [31:0] instr_extend;
    logic [27:0] instr_shift;
    logic [31:0] instr_extend_shift;
    logic [31:0] write_data;
    logic [31:0] alu_op1;
    logic [31:0] alu_op2;
    logic [31:0] alu_res;
    logic [31:0] reg_file_read_data;
    logic [31:0] data_memory_read_data;
    logic [31:0] branch_target_address;
    logic [31:0] branch_or_plus4_address;
    logic [4:0]  write_reg;
    logic [3:0]  alu_control_input;
    logic [1:0]  control_alu_op;
    logic        reg_dst;
    logic        reg_write;
    logic        alu_src;
    logic        zero;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        jump;
    logic        branch_eq;
    logic        branch_ne;
    logic        pc_src;

    // === IF (Instruction Fetch) ===
    
    program_counter pc_inst(
        .in(pc_next),
        .clk(clk),
        .reset(reset),
        .out(pc_current)
    );
    
    adder adder_pc(
        .op1(32'd4),
        .op2(pc_current),
        .sum(pc_plus_4)
    );
    
    instruction_memory instruction_memory_inst(
        .address(pc_current),
        .instruction(instr)
    );
    
    // === ID (Instruction Decode) ===
    
    control control_inst(
        .opcode(instr[31:26]),
        .jump(jump),
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_op(control_alu_op),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .reg_dst(reg_dst)
    );
    
    reg_file reg_file_inst(
        .read_reg_1(instr[25:21]),
        .read_reg_2(instr[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write(reg_write),
        .clk(clk),
        .read_data_1(alu_op1),
        .read_data_2(reg_file_read_data)
    );
    
    sign_extend sign_extend_inst(
        .in(instr[15:0]),
        .out(instr_extend)
    );
    
    // === EX (Execute) ===
    
    alu_control alu_control_inst(
        .funct(instr[5:0]),
        .alu_op(control_alu_op),
        .alu_control(alu_control_input)
    );
    
    shift_left_2 shift_instr_extend(
        .in(instr_extend),
        .out(instr_extend_shift)
    );
    
    adder adder_branch_address(
        .op1(pc_plus_4),
        .op2(instr_extend_shift),
        .sum(branch_target_address)
    );
    
    mux2 #(5) mux2_reg_dst(
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .out(write_reg)
    );
    
    mux2 mux2_alu_src(
        .a(reg_file_read_data),
        .b(instr_extend),
        .sel(alu_src),
        .out(alu_op2)
    );
    
    alu alu_inst(
        .op1(alu_op1),
        .op2(alu_op2),
        .alu_control(alu_control_input),
        .res(alu_res),
        .zero(zero)
    );
    
    // === Branch & Jump Logic ===
    
    branch_control branch_control_inst(
        .zero(zero),
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .pc_src(pc_src)
    ); 

    mux2 mux2_pc_src(
        .a(pc_plus_4),
        .b(branch_target_address),
        .sel(pc_src),
        .out(branch_or_plus4_address)
    );
    
    shift_left_2 #(28) shift_instr(
        .in(instr[25:0]),
        .out(instr_shift)
    );

    mux2 mux2_jump(
        .a(branch_or_plus4_address),
        .b({pc_plus_4[31:28], instr_shift}),
        .sel(jump),
        .out(pc_next)
    );
    
    // === MEM (Memory Access) ===
    
    data_memory data_memory_inst(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_res),
        .write_data(reg_file_read_data),
        .read_data(data_memory_read_data)
    );
    
    // === WB (Write Back) ===
    
    mux2 mux2_mem_to_reg(
        .a(alu_res),
        .b(data_memory_read_data),
        .sel(mem_to_reg),
        .out(write_data)
    );   
endmodule
