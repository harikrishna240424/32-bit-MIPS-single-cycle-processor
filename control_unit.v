// ============================================================
// control_unit.v  –  Main Control Unit
// Decodes the 6-bit opcode and asserts control signals.
// ============================================================
`timescale 1ns/1ps

module control_unit (
    input  wire [5:0] opcode,
    output reg        reg_dst,
    output reg        jump,
    output reg        branch,
    output reg        mem_read,
    output reg        mem_to_reg,
    output reg  [1:0] alu_op,
    output reg        mem_write,
    output reg        alu_src,
    output reg        reg_write
);
    // Opcode encodings (MIPS subset)
    localparam R_TYPE = 6'b000000;
    localparam LW     = 6'b100011;
    localparam SW     = 6'b101011;
    localparam BEQ    = 6'b000100;
    localparam ADDI   = 6'b001000;
    localparam ANDI   = 6'b001100;
    localparam ORI    = 6'b001101;
    localparam SLTI   = 6'b001010;
    localparam J      = 6'b000010;

    always @(*) begin
        // Defaults (safe)
        reg_dst    = 1'b0;
        jump       = 1'b0;
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        alu_op     = 2'b00;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        reg_write  = 1'b0;

        case (opcode)
            R_TYPE: begin
                reg_dst   = 1'b1;
                alu_op    = 2'b10;   // ALU ctrl uses funct field
                reg_write = 1'b1;
            end
            LW: begin
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_src    = 1'b1;   // use immediate
                reg_write  = 1'b1;
                alu_op     = 2'b00;  // ADD
            end
            SW: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;  // ADD
            end
            BEQ: begin
                branch = 1'b1;
                alu_op = 2'b01;    // SUB (compare)
            end
            ADDI: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b00;  // ADD
            end
            ANDI: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b11;  // AND immediate
            end
            ORI: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b11;  // OR immediate (ALU ctrl distinguishes)
            end
            SLTI: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b11;
            end
            J: begin
                jump = 1'b1;
            end
            default: begin
                // NOP / undefined
            end
        endcase
    end
endmodule
