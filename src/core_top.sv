`timescale 1ns / 1ps
`include "program_counter.sv"
`include "instruction_memory.sv"
`include "decode.sv"
`include "register_file.sv"
`include "comperator.sv"
`include "alu.sv"


module core_top(
    input wire clk,
    input wire reset
    );
    
    wire [31:0] pc;
    wire [31:0] branch_target;

    wire take_branch;
    wire stall = 0;

    program_counter program_counter_instance (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .branch_target(branch_target),
        .branch_taken(take_branch),
        .pc(pc)
    );

    wire [31:0] instr;

    instruction_memory i_mem (
        .reset(reset),
        .addr(pc),
        .data(instr)
    );

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [31:0] imm;

    wire is_addi;
    wire is_add;
    wire write_en;

    wire is_beq;
    wire is_bne;
    wire is_blt;
    wire is_bge;
    wire is_bltu;
    wire is_bgeu;

    decode decoder (
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .is_addi(is_addi),
        .is_add(is_add),
        .is_beq(is_beq),
        .is_bne(is_bne),
        .is_blt(is_blt),
        .is_bge(is_bge),
        .is_bltu(is_bltu),
        .is_bgeu(is_bgeu),

        .rd_valid(write_en)
    );
    
    
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] result;

    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .write_en(write_en),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(rd),
        .rd_data(result),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    alu alu_instance (
        .operand1(rs1_data),
        .operand2(rs2_data),
        .imm(imm),
        .is_addi(is_addi),
        .is_add(is_add),
        .result(result)
    );

    comperator comperator_instance (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .is_beq(is_beq),
        .is_bne(is_bne),
        .is_blt(is_blt),
        .is_bge(is_bge),
        .is_bltu(is_bltu),
        .is_bgeu(is_bgeu),
        .take_branch(take_branch)
    );
    
    assign branch_target = pc + imm;

endmodule
