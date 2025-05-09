import instruction_utils::*;

// Execute stage of the pipeline, without the LSU
module execute_stage(
    input clk,
    input rst,
    input stall,
    input rv32i_instr_e id_ex_instr_type,
    input logic [ 4:0] id_ex_rs1_addr,
    input logic [31:0] id_ex_rs1_data,
    input logic [ 4:0] id_ex_rs2_addr,
    input logic [31:0] id_ex_rs2_data,
    input logic [31:0] id_ex_imm,
    input logic [31:0] id_ex_pc,
    input logic [ 4:0] id_ex_rd_addr,
    input logic        id_ex_write_en,
    input logic [ 4:0] wb_ex_rd_addr, // forwarding
    input logic [31:0] wb_ex_rd_data,

    output logic        ex_if_take_branch, // -> fetch stage
    output logic [31:0] ex_if_branch_target, // -> fetch stage
    output logic [31:0] ex_wb_result,
    output logic        ex_wb_write_en,
    output logic [ 4:0] ex_wb_rd_addr,
    output logic [31:0] mem_addr // -> data memory, unbuffered
);

    // Forwarding
    wire logic [31:0] rs1_data;
    wire logic [31:0] rs2_data;
    assign rs1_data = (id_ex_rs1_addr == wb_ex_rd_addr && wb_ex_rd_addr != 32'b0) ? wb_ex_rd_data : id_ex_rs1_data;
    assign rs2_data = (id_ex_rs2_addr == wb_ex_rd_addr && wb_ex_rd_addr != 32'b0) ? wb_ex_rd_data : id_ex_rs2_data;

    // TODO don't buffer branch result to branch 1 cycle sooner
    wire logic ex_take_branch;
    wire logic [31:0] ex_branch_target;
    wire logic [31:0] ex_result;

    assign mem_addr = ex_result;

    alu alu_instance (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .imm(id_ex_imm),
        .pc(id_ex_pc),
        .instr(id_ex_instr_type),

        .take_branch(ex_take_branch),
        .branch_target(ex_branch_target),
        .result(ex_result)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            ex_if_take_branch <= 0;
            ex_if_branch_target <= 0;
            ex_wb_result <= 0;
            ex_wb_write_en <= 0;
            ex_wb_rd_addr <= 0;
        end else if (!stall) begin
            ex_if_take_branch <= ex_take_branch;
            ex_if_branch_target <= ex_branch_target;
            ex_wb_result <= ex_result;
            ex_wb_write_en <= id_ex_write_en;
            ex_wb_rd_addr <= id_ex_rd_addr;
        end
    end
endmodule
