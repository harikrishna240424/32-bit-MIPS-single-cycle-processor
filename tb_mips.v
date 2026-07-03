// ============================================================
// tb_mips.v  –  Testbench for MIPS Single-Cycle Processor
// Simulates 200 ns with clock period = 10 ns.
// ============================================================
`timescale 1ns/1ps

module tb_mips;
    reg clk, reset;

    // Instantiate DUT
    mips_single_cycle DUT (
        .clk   (clk),
        .reset (reset)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Dump waveforms
    initial begin
        $dumpfile("mips_wave.vcd");
        $dumpvars(0, tb_mips);
    end

    // Stimulus
    initial begin
        $display("=== MIPS Single-Cycle Simulation Start ===");
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        // Run for 20 cycles
        repeat(20) @(posedge clk);

        $display("=== Simulation End ===");
        $display("PC = %0h", DUT.pc);
        $display("$t0 (R8)  = %0d", DUT.REGFILE.regs[8]);
        $display("$t1 (R9)  = %0d", DUT.REGFILE.regs[9]);
        $display("$t2 (R10) = %0d", DUT.REGFILE.regs[10]);
        $display("$t3 (R11) = %0d", DUT.REGFILE.regs[11]);
        $display("DMEM[0]   = %0d", DUT.DMEM.mem[0]);
        $finish;
    end

    // Cycle monitor
    always @(posedge clk) begin
        if (!reset)
            $display("t=%0t | PC=%0h | instr=%h | ALUres=%0d | zero=%b",
                $time, DUT.pc, DUT.instr, DUT.alu_result, DUT.zero);
    end
endmodule
