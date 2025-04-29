import instruction_utils::*;

module decode_stage(
    input wire logic clk,
    input wire logic rst,
    input wire logic stall,
    input wire logic [31:0] instr,
    input wire logic [4:0] wb_id_rd_addr, // write from the wb stage
    input wire logic wb_id_wr_en, // write from the wb stage
    input wire logic [31:0] wb_id_rd_data, // write from the wb stage

    output rv32i_instr_e instr_type,
    output logic [31:0] rs1,
    output logic [31:0] rs2,
    output logic [31:0] imm,
    output logic [4:0] rd_addr,
    output logic write_en
);

    wire logic [4:0] rs1_addr; // into register file
    wire logic [4:0] rs2_addr; // into register file
    wire logic [4:0] id_rd_addr; // into ff, to exe stage
    wire logic id_write_en; // into ff, to exe stage
    wire logic [31:0] id_imm; // into ff, to exe stage
    rv32i_instr_e id_opcode; // into ff, to exe stage

    decode decode_instance (
        .instr(instr), // from if

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
        .rs1_addr(rs1_addr), // to exe stage
        .rs2_addr(rs2_addr), // to exe stage
        .write_en(wb_id_wr_en), // from wb stage
        .rd_addr(wb_id_rd_addr), // from wb stage
        .rd_data(wb_id_rd_data), // from wb stage

        .rs1_data(rs1), // to exe stage
        .rs2_data(rs2) // to exe stage
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            imm <= 0;
            instr_type <= INSTR_NOP;
            rd_addr <= 0;
            write_en <= 0;
        end else if (!stall) begin
            imm <= id_imm;
            instr_type <= id_opcode;
            rd_addr <= id_rd_addr;
            write_en <= id_write_en;
        end
    end
endmodule
