`timescale 1ns / 1ps

module tb_mips;

    logic        clk;
    logic        reset;

    logic [31:0] final_t0, final_t1, final_t2;
    logic [31:0] final_mem_val;

    mips dut( 
        .clk(clk), 
        .reset(reset) 
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("--- Pornire Test Final MIPS Single-Cycle ---");

        reset = 1;
        #15;
        reset = 0;
        $display("T=15ns: Reset dezactivat. Executie program...");
        #160;

        $display("\n--- Verificare Stare Finala ---");
        
        final_t0 = dut.reg_file_inst.registers[8];  // $t0
        final_t1 = dut.reg_file_inst.registers[9];  // $t1
        final_t2 = dut.reg_file_inst.registers[10]; // $t2
        
        final_mem_val = dut.data_memory_inst.ram[64];

        $display("Verificare Registru $t0: Asteptat = 5,    Obtinut = %d", final_t0);
        $display("Verificare Registru $t1: Asteptat = 15,   Obtinut = %d", final_t1);
        $display("Verificare Registru $t2: Asteptat = 15,   Obtinut = %d", final_t2);
        $display("Verificare Mem[256]:    Asteptat = 15,   Obtinut = %d", final_mem_val);
        
        if (final_t0 == 5 && final_t1 == 15 && final_t2 == 15 && final_mem_val == 15) begin
            $display("\n>>> TESTUL A TRECUT! Procesorul single-cycle este functional.");
        end else begin
            $display("\n>>> TESTUL A ESUAT!");
        end

        #20;
        $finish;
    end

endmodule