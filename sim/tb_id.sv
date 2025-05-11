`timescale 1ns / 1ps

import instruction_utils::*;

module tb_id;

    localparam CLK_PERIOD = 10;
    logic clk = 0;
    logic rst;
    logic stall = 0;
    logic [31:0] instr;
    logic [31:0] if_id_pc;
    logic [4:0] wb_id_rd_addr;
    logic wb_id_wr_en;
    logic [31:0] wb_id_rd_data;

    rv32i_instr_e instr_type;
    logic [ 4:0] rs1_addr;
    logic [ 4:0] rs2_addr;
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] imm;
    logic [31:0] id_ex_pc;
    logic [4:0] rd_addr;
    logic write_en;
    logic stall_if;

    logic [31:0] instructions [0:64];
    integer pc = 0;

    assign if_id_pc = pc*4;
    

    decode_stage dut (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .if_id_instr_data(instr),
        .if_id_pc(if_id_pc),
        .wb_id_rd_addr(wb_id_rd_addr),
        .wb_id_wr_en(wb_id_wr_en),
        .wb_id_rd_data(wb_id_rd_data),
        
        .id_ex_instr_type(instr_type),
        .id_ex_rs1_addr(rs1_addr),
        .id_ex_rs2_addr(rs2_addr),
        .id_ex_rs1_data(rs1),
        .id_ex_rs2_data(rs2),
        .id_ex_imm(imm),
        .id_ex_pc(id_ex_pc),
        .id_ex_rd_addr(rd_addr),
        .id_ex_write_en(write_en),
        .stall_if(stall_if)
    );

    always #(CLK_PERIOD/2) clk <= !clk;

    // monitoring
    initial begin
        forever @(posedge clk) begin
            $display("stall=%b, instr=%08h=%s, rs1=%0d, rs2=%0d, imm=%0d, rd=%0d, wr_en=%b, pc=%08h",
                stall, instr, instruction_utils::disassemble(instr), rs1, rs2, imm, rd_addr, write_en, id_ex_pc);
        end
    end

    // seting up registers and instructions
    initial begin
        $readmemh("./sim/instr_test.hex", instructions);
        @(negedge clk); // waiting for the reset to end
        for (int i = 1; i<32; i = i + 1) begin
            dut.reg_file.registers[i] = i;
        end
    end


    // dump traces
    initial begin
        $dumpfile("sim/tb_id.fst");
        $dumpvars(0,tb_id);
    end

    // simulating instruction inflow
    initial begin
        $display("Starting Testbench, reseting...");
        instr <= instructions[0];
        rst <= 1;
        @(negedge clk); // waiting for reset to take effect
        rst <= 0;
        forever @(posedge clk) begin
            if (pc == 60) begin
                $finish;
            end
            if (!rst) begin
                instr <= instructions[pc];
                pc <= pc + 1;
            end
        end
    end
endmodule
