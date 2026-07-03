// ============================================================
// inst_memory.v  –  Instruction Memory (ROM, word-addressed)
// 256 words × 32-bit  (1 KB).  Pre-loaded from "program.mem".
// ============================================================
`timescale 1ns/1ps

module inst_memory #(
    parameter MEM_SIZE = 256   // number of 32-bit words
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:MEM_SIZE-1];
    integer i;

    initial begin
        // Clear memory
        for (i = 0; i < MEM_SIZE; i = i+1)
            mem[i] = 32'b0;

        // -------- Load program from hex file (optional) --------
        // Uncomment and create program.mem with one hex word per line:
        // $readmemh("program.mem", mem);

        // -------- Hard-coded sample program (comment out if using file) --------
        // addi $t0, $zero, 5   → 0x20080005
        mem[0] = 32'h20080005;
        // addi $t1, $zero, 10  → 0x20090000 + 10 = 0x2009000A
        mem[1] = 32'h2009000A;
        // add  $t2, $t0, $t1   → R-type: op=0,rs=8,rt=9,rd=10,shamt=0,funct=32
        mem[2] = 32'h01095020;   // add $t2, $t0, $t1
        // sw   $t2, 0($zero)   → 0xAC0A0000
        mem[3] = 32'hAC0A0000;
        // lw   $t3, 0($zero)   → 0x8C0B0000
        mem[4] = 32'h8C0B0000;
        // beq  $t2,$t3, +1     → 0x114B0001  (branch forward 1)
        mem[5] = 32'h114B0001;
        // addi $t0,$t0,1 (skipped if branch taken)
        mem[6] = 32'h21080001;
        // j    0               → 0x08000000  (halt loop)
        mem[7] = 32'h08000007;   // j to self
    end

    // Word-aligned read (byte address → word index)
    assign instr = mem[addr[31:2]];

endmodule


// ============================================================
// data_memory.v  –  Data Memory (RAM, word-addressed)
// 256 words × 32-bit  (1 KB).  Synchronous writes, async reads.
// ============================================================
`timescale 1ns/1ps

module data_memory #(
    parameter MEM_SIZE = 256
)(
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:MEM_SIZE-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_SIZE; i = i+1)
            mem[i] = 32'b0;
        // Optional: $readmemh("data.mem", mem);
    end

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write)
            mem[addr[31:2]] <= write_data;
    end

    // Asynchronous read
    assign read_data = mem_read ? mem[addr[31:2]] : 32'b0;

endmodule
