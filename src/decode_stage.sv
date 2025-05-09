import instruction_utils::*;

module decode_stage(
    input wire logic clk,
    input wire logic rst,
    input wire logic stall,
    input wire logic [31:0] if_id_instr_data,
    input wire logic [31:0] if_id_pc,
    input wire logic        wb_id_wr_en, // write from the wb stage
    input wire logic [ 4:0] wb_id_rd_addr, // write from the wb stage
    input wire logic [31:0] wb_id_rd_data, // write from the wb stage

    output rv32i_instr_e id_ex_instr_type,
    output logic [31:0] id_ex_rs1_data,
    output logic [31:0] id_ex_rs2_data,
    output logic [31:0] id_ex_imm,
    output logic [31:0] id_ex_pc,
    output logic [ 4:0] id_ex_rd_addr,
    output logic        id_ex_write_en
);

    wire logic [4:0] rs1_addr; // into register file
    wire logic [4:0] rs2_addr; // into register file
    wire logic [4:0] id_rd_addr; // into ff, to exe stage
    wire logic id_write_en; // into ff, to exe stage
    wire logic [31:0] id_imm; // into ff, to exe stage
    rv32i_instr_e id_opcode; // into ff, to exe stage

    decode decode_instance (
        .instr(if_id_instr_data), // from if

        .rs1(rs1_addr), // into register file, to exe stage 
        .rs2(rs2_addr), // into register file, to exe stage 
        .rd(id_rd_addr), // into ff, to exe stage
        .imm(id_imm), // into ff, to exe stage
        .rd_write_en(id_write_en),
        .instr_type(id_opcode)
    );

    register_file register_file_instance (
        .clk(clk),
        .reset(rst),
        .stall(stall),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .write_en(wb_id_wr_en), // from wb stage
        .rd_addr(wb_id_rd_addr), // from wb stage
        .rd_data(wb_id_rd_data), // from wb stage

        .rs1_data(id_ex_rs1_data), // to exe stage
        .rs2_data(id_ex_rs2_data) // to exe stage
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            id_ex_imm <= 0;
            id_ex_instr_type <= INSTR_NOP;
            id_ex_rd_addr <= 0;
            id_ex_write_en <= 0;
            id_ex_pc <= 0;
        end else if (!stall) begin
            id_ex_imm <= id_imm;
            id_ex_instr_type <= id_opcode;
            id_ex_rd_addr <= id_rd_addr;
            id_ex_write_en <= id_write_en;
            id_ex_pc <= if_id_pc;
        end
    end
endmodule
