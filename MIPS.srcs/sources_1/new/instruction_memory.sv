`timescale 1ns / 1ps

module instruction_memory(
    input  logic [31:0] address,
    output logic [31:0] instruction
    );
    
    logic [31:0] rom [0:1023];
    
    initial begin
        rom[0]  = 32'h20080005; // addi $t0, $zero, 5
        rom[1]  = 32'h2009000A; // addi $t1, $zero, 10
        rom[2]  = 32'h01095020; // add  $t2, $t0, $t1
        rom[3]  = 32'h01485022; // sub  $t2, $t2, $t0
        rom[4]  = 32'h012A5024; // and  $t2, $t1, $t2
        rom[5]  = 32'h01485025; // or   $t2, $t2, $t0
        rom[6]  = 32'hAC0A0100; // sw   $t2, 0x100($zero)
        rom[7]  = 32'h8C090100; // lw   $t1, 0x100($zero)
        rom[8]  = 32'h112A0001; // beq  $t1, $t2, +1 (sari o instructiune)
        rom[9]  = 32'h200A0063; // addi $t2, $zero, 99 (NU se executa)
        rom[10] = 32'h15280001; // bne  $t1, $t0, +1 (sari o instructiune)
        rom[11] = 32'h200A004D; // addi $t2, $zero, 77 (NU se executa)
        rom[12] = 32'h0800000E; // j    exit (rom[14])
        rom[13] = 32'h200A0042; // addi $t2, $zero, 66 (NU se executa)
        rom[14] = 32'h00000000; // exit: nop
    end
    
    assign instruction = rom[address[31:2]];
    
endmodule
