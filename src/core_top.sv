`timescale 1ns / 1ps

import instruction_utils::*;

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

    wire rd_write_en;

    rv32i_instr_e decoded_instr;

    decode decoder (
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .rd_write_en(rd_write_en),
        .instr_type(decoded_instr)
    );
    
    
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] result;

    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .write_en(rd_write_en),
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
        .pc(pc),
        .instr(decoded_instr),
        .result(result)
    );

    comperator comperator_instance (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .instr(decoded_instr),
        .take_branch(take_branch)
    );
    
    assign branch_target = pc + imm;

endmodule
