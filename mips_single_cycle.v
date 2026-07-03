// ============================================================
// mips_single_cycle.v  –  Top-Level MIPS Single-Cycle Processor
// Textbook: Patterson & Hennessy "Computer Organization and Design"
// ============================================================
`timescale 1ns/1ps

module mips_single_cycle (
    input  wire        clk,
    input  wire        reset
);
    // ----- Internal wires -----
    wire [31:0] pc, pc_next, pc_plus4, pc_branch;
    wire [31:0] instr;
    wire [31:0] reg_data1, reg_data2, alu_result, read_data, write_data;
    wire [31:0] sign_ext, shift_left2, alu_b;
    wire [4:0]  write_reg;
    wire [3:0]  alu_ctrl;
    wire [1:0]  alu_op;
    wire        zero;
    wire        reg_dst, jump, branch, mem_read, mem_to_reg;
    wire        mem_write, alu_src, reg_write;

    // ----- Program Counter -----
    program_counter PC (
        .clk    (clk),
        .reset  (reset),
        .pc_in  (pc_next),
        .pc_out (pc)
    );

    // PC + 4
    assign pc_plus4 = pc + 32'd4;

    // ----- Instruction Memory -----
    inst_memory IMEM (
        .addr  (pc),
        .instr (instr)
    );

    // ----- Control Unit -----
    control_unit CTRL (
        .opcode     (instr[31:26]),
        .reg_dst    (reg_dst),
        .jump       (jump),
        .branch     (branch),
        .mem_read   (mem_read),
        .mem_to_reg (mem_to_reg),
        .alu_op     (alu_op),
        .mem_write  (mem_write),
        .alu_src    (alu_src),
        .reg_write  (reg_write)
    );

    // ----- Register File -----
    // Write register: rt (R-type→rd, I-type→rt)
    assign write_reg  = reg_dst ? instr[15:11] : instr[20:16];
    assign write_data = mem_to_reg ? read_data : alu_result;

    register_file REGFILE (
        .clk        (clk),
        .reg_write  (reg_write),
        .read_reg1  (instr[25:21]),   // rs
        .read_reg2  (instr[20:16]),   // rt
        .write_reg  (write_reg),
        .write_data (write_data),
        .read_data1 (reg_data1),
        .read_data2 (reg_data2)
    );

    // ----- Sign Extension -----
    sign_extend SEXT (
        .in  (instr[15:0]),
        .out (sign_ext)
    );

    // ----- ALU Input Mux -----
    assign alu_b = alu_src ? sign_ext : reg_data2;

    // ----- ALU Control -----
    alu_control ALU_CTRL (
        .alu_op   (alu_op),
        .funct    (instr[5:0]),
        .alu_ctrl (alu_ctrl)
    );

    // ----- ALU -----
    alu ALU (
        .a        (reg_data1),
        .b        (alu_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (zero)
    );

    // ----- Data Memory -----
    data_memory DMEM (
        .clk       (clk),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .addr      (alu_result),
        .write_data(reg_data2),
        .read_data (read_data)
    );

    // ----- Branch Target -----
    assign shift_left2 = {sign_ext[29:0], 2'b00};      // << 2
    assign pc_branch   = pc_plus4 + shift_left2;

    // ----- Next PC Logic -----
    wire branch_taken = branch & zero;
    wire [31:0] pc_after_branch = branch_taken ? pc_branch : pc_plus4;
    // Jump: PC[31:28] | imm26 << 2
    wire [31:0] pc_jump = {pc_plus4[31:28], instr[25:0], 2'b00};
    assign pc_next = jump ? pc_jump : pc_after_branch;

endmodule
