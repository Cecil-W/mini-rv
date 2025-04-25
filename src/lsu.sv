`timescale 1ns/1ps

import instruction_utils::*;

module lsu(
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [31:0] imm,
    input rv32i_instr_e instr,
    input logic [31:0] load_data,
    
    output logic [31:0] address,
    output logic mem_wb_en, // setting the register file target to store mem output instead of alu result
    output logic [31:0] mem_wb, 
    output logic write_en, // write enable for store instructions
    output logic read_en,
    output logic [ 1:0] store_size, // 00 = byte, 01 = half, 10 = word
    output logic [31:0] store_data
);

    // could move this into the alu, and take the address from a port
    assign address = rs1 + imm;

    // constant select signals to avoid iverilog errors
    wire [7:0] load_data_b = load_data[7:0];
    wire load_data_b_msb = load_data[7];
    wire [15:0] load_data_h = load_data[15:0];
    wire load_data_h_msb = load_data[15];
    wire [7:0] rs2_b = rs2[7:0];
    wire [15:0] rs2_h = rs2[15:0];

    always_comb begin
        // defaults
        mem_wb_en = 0;
        mem_wb = 32'b0;
        write_en = 0;
        read_en = 0;
        store_size = 2'b00;
        store_data = 32'b0;
        case (instr)
            // I-Type (Load)
            INSTR_LB : begin
                mem_wb_en = 1;
                read_en = 1;
                mem_wb = {{24{load_data_b_msb}}, load_data_b};
            end
            INSTR_LH : begin
                mem_wb_en = 1;
                read_en = 1;
                mem_wb = {{16{load_data_h_msb}}, load_data_h};
            end
            INSTR_LW : begin
                mem_wb_en = 1;
                read_en = 1;
                mem_wb = load_data;
            end
            INSTR_LBU :begin
                mem_wb_en = 1;
                read_en = 1;
                mem_wb = {{24{1'b0}}, load_data_b};
            end
            INSTR_LHU : begin
                mem_wb_en = 1;
                read_en = 1;
                mem_wb = {{16{1'b0}}, load_data_h};
            end
            
            // S-Type (Store)
            INSTR_SB : begin
                write_en   = 1;
                store_size = 2'b00;
                store_data = rs2_b;
            end
            INSTR_SH : begin
                write_en   = 1;
                store_size = 2'b01;
                store_data = rs2_h;
            end
            INSTR_SW : begin
                write_en   = 1;
                store_size = 2'b10;
                store_data = rs2;
            end
            default : begin
                mem_wb_en = 0;
                mem_wb = 32'b0;
                write_en = 0;
                read_en = 0;
                store_size = 2'b10;
                store_data = 32'b0;
            end
        endcase
    end
endmodule


