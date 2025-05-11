import instruction_utils::*;

// Execute stage of the pipeline, without the LSU
module execute_stage(
    input clk,
    input rst,
    input stall,
    input rv32i_instr_e id_ex_instr_type,
    input logic [31:0] ex_fwd_rs1_data,
    input logic [31:0] ex_fwd_rs2_data,
    input logic [31:0] id_ex_imm,
    input logic [31:0] id_ex_pc,
    input logic [ 4:0] id_ex_rd_addr,
    input logic        id_ex_write_en,

    output logic        ex_if_take_branch,
    output logic [31:0] ex_if_branch_target,
    output logic [31:0] ex_wb_result,
    output logic        ex_wb_write_en,
    output logic [ 4:0] ex_wb_rd_addr,
    output logic [31:0] mem_addr // -> data memory, unbuffered
);

    wire logic [31:0] ex_result;
    assign mem_addr = ex_result;

    alu alu_instance (
        .rs1(ex_fwd_rs1_data),
        .rs2(ex_fwd_rs2_data),
        .imm(id_ex_imm),
        .pc(id_ex_pc),
        .instr(id_ex_instr_type),

        .take_branch(ex_if_take_branch),
        .branch_target(ex_if_branch_target),
        .result(ex_result)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            ex_wb_result <= 0;
            ex_wb_write_en <= 0;
            ex_wb_rd_addr <= 0;
        end else if (!stall) begin
            ex_wb_result <= ex_result;
            ex_wb_write_en <= id_ex_write_en;
            ex_wb_rd_addr <= id_ex_rd_addr;
        end
    end
endmodule
