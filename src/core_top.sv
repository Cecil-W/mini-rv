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
    wire [31:0] alu_result;
    wire mem_wb_en;
    wire [31:0] rd_data;
    wire [31:0] mem_wb;

    assign rd_data = mem_wb_en ? mem_wb : alu_result;

    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .write_en(rd_write_en),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(rd),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    alu alu_instance (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .imm(imm),
        .pc(pc),
        .instr(decoded_instr),
        .take_branch(take_branch),
        .branch_target(branch_target),
        .result(alu_result)
    );

    // from d mem to lsu
    wire [31:0] load_data;
    // from lsu to mem
    wire [31:0] mem_address;
    wire write_en;
    wire [1:0] store_size;
    wire [31:0] store_data;

    lsu lsu_instance (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .imm(imm),
        .instr(decoded_instr),
        .load_data(load_data),
        .address(mem_address),
        .mem_wb_en(mem_wb_en),
        .mem_wb(mem_wb),
        .write_en(write_en),
        .store_size(store_size),
        .store_data(store_data)
    );

    data_memory #(
        .MEM_SIZE(64)
    ) data_memory_instance (
        .clk(clk),
        .reset(reset),
        .write_en(write_en),
        .addr(mem_address),
        .store_size(store_size),
        .store_data(store_data),
        .load_data(load_data)
    );
endmodule
