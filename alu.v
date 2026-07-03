// ============================================================
// alu_control.v  –  ALU Control Unit
// Combines ALUOp (from main control) with funct field to
// produce a 4-bit ALU operation code.
// ============================================================
`timescale 1ns/1ps

module alu_control (
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,
    output reg  [3:0] alu_ctrl
);
    // ALU control output encodings
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;
    localparam ALU_NOR = 4'b1100;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SLL = 4'b1000;
    localparam ALU_SRL = 4'b1001;

    // funct field encodings (R-type)
    localparam F_ADD = 6'b100000;
    localparam F_ADDU= 6'b100001;
    localparam F_SUB = 6'b100010;
    localparam F_AND = 6'b100100;
    localparam F_OR  = 6'b100101;
    localparam F_XOR = 6'b100110;
    localparam F_NOR = 6'b100111;
    localparam F_SLT = 6'b101010;
    localparam F_SLL = 6'b000000;
    localparam F_SRL = 6'b000010;

    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = ALU_ADD;   // lw / sw / addi
            2'b01: alu_ctrl = ALU_SUB;   // beq
            2'b10: begin                  // R-type: decode funct
                case (funct)
                    F_ADD,F_ADDU: alu_ctrl = ALU_ADD;
                    F_SUB:        alu_ctrl = ALU_SUB;
                    F_AND:        alu_ctrl = ALU_AND;
                    F_OR:         alu_ctrl = ALU_OR;
                    F_XOR:        alu_ctrl = ALU_XOR;
                    F_NOR:        alu_ctrl = ALU_NOR;
                    F_SLT:        alu_ctrl = ALU_SLT;
                    F_SLL:        alu_ctrl = ALU_SLL;
                    F_SRL:        alu_ctrl = ALU_SRL;
                    default:      alu_ctrl = ALU_ADD;
                endcase
            end
            2'b11: alu_ctrl = ALU_AND;   // andi/ori/slti placeholder
            default: alu_ctrl = ALU_ADD;
        endcase
    end
endmodule


// ============================================================
// alu.v  –  32-bit ALU
// ============================================================
`timescale 1ns/1ps

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero,
    output wire        overflow
);
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;
    localparam ALU_SLL = 4'b1000;
    localparam ALU_SRL = 4'b1001;
    localparam ALU_NOR = 4'b1100;

    wire [31:0] sum   = a + b;
    wire [31:0] diff  = a - b;

    always @(*) begin
        case (alu_ctrl)
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_ADD: result = sum;
            ALU_XOR: result = a ^ b;
            ALU_SUB: result = diff;
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLL: result = b << a[4:0];  // shamt in lower 5 bits of a
            ALU_SRL: result = b >> a[4:0];
            ALU_NOR: result = ~(a | b);
            default: result = 32'b0;
        endcase
    end

    assign zero     = (result == 32'b0);
    // Signed overflow for ADD/SUB
    assign overflow = (alu_ctrl == ALU_ADD) ?
                          (a[31]==b[31]) && (sum[31]!=a[31]) :
                      (alu_ctrl == ALU_SUB) ?
                          (a[31]!=b[31]) && (diff[31]!=a[31]) : 1'b0;
endmodule
