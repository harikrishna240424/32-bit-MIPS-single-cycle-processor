// ============================================================
// register_file.v  –  32×32 Register File
// $0 is hardwired to zero; writes are synchronous (rising edge),
// reads are combinational (async).
// ============================================================
`timescale 1ns/1ps

module register_file (
    input  wire        clk,
    input  wire        reg_write,
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;

    // Initialise all registers to 0
    initial begin
        for (i = 0; i < 32; i = i+1)
            regs[i] = 32'b0;
    end

    // Synchronous write (write-back at rising edge)
    always @(posedge clk) begin
        if (reg_write && write_reg != 5'b0)  // $0 always 0
            regs[write_reg] <= write_data;
    end

    // Asynchronous read; $0 always returns 0
    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : regs[read_reg2];

endmodule


// ============================================================
// program_counter.v  –  32-bit Program Counter
// Synchronous load, synchronous active-high reset to 0.
// ============================================================
`timescale 1ns/1ps

module program_counter (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= pc_in;
    end
endmodule


// ============================================================
// sign_extend.v  –  16-bit → 32-bit Sign Extension
// ============================================================
`timescale 1ns/1ps

module sign_extend (
    input  wire [15:0] in,
    output wire [31:0] out
);
    assign out = {{16{in[15]}}, in};
endmodule
