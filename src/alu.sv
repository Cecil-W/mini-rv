`timescale 1ns / 1ps

import instruction_utils::*;

module alu(
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [31:0] imm,
    input logic [31:0] pc,
    input rv32i_instr_e instr,

    output logic take_branch,
    output logic [31:0] branch_target,
    output logic [31:0] result
);

    always_comb begin
        // defaults
        take_branch = 0;
        branch_target = pc + imm;
        result = 32'b0;
        case (instr)
            // J-Type
            INSTR_JAL : begin
                result = pc + 4;
                take_branch = 1;
                branch_target = pc + imm;
            end
            INSTR_JALR : begin
                result = pc + 4;
                take_branch = 1;
                branch_target = (rs1 + imm) & !32'b1;
            end
            // U-Type
            INSTR_AUIPC : result = pc + imm;
            INSTR_LUI   : result = imm;
            // B-Type
            INSTR_BEQ  : take_branch = rs1 == rs2;
            INSTR_BNE  : take_branch = rs1 != rs2;
            INSTR_BLT  : take_branch = (rs1 < rs2) ^ (rs1[31] != rs2[31]);
            INSTR_BGE  : take_branch = (rs1 >= rs2) ^ (rs1[31] != rs2[31]);
            INSTR_BLTU : take_branch = rs1 < rs2;
            INSTR_BGEU : take_branch = rs1 >= rs2;
            // I-Type (ALU Immediate)
            INSTR_ADDI  : result = rs1 + imm;
            INSTR_XORI  : result = rs1 ^ imm;
            INSTR_ORI   : result = rs1 | imm;
            INSTR_ANDI  : result = rs1 & imm;
            // This dynamic casting causes a segfault in iverilog
            // INSTR_SLTI  : result = ($signed'(operand1) < $signed'(imm)) ? 32'b1 : 32'b0;
            INSTR_SLTI  : result = ((rs1 < imm) ^ (rs1[31] != imm[31])) ? 32'b1 : 32'b0;
            INSTR_SLTIU : result = rs1 < imm ? 32'b1 : 32'b0;
            INSTR_SLLI  : result = rs1 << imm[4:0];
            INSTR_SRLI  : result = rs1 >> imm[4:0];
            INSTR_SRAI  : result = rs1 >>> imm[4:0];

            // R-Type (Register-Register ALU)
            INSTR_ADD  : result = rs1 + rs2;
            INSTR_SUB  : result = rs1 - rs2;
            INSTR_XOR  : result = rs1 ^ rs2;
            INSTR_OR   : result = rs1 | rs2;
            INSTR_AND  : result = rs1 & rs2;
            INSTR_SLL  : result = rs1 <<  rs2[4:0]; // on rv64 shift by rs2[5:0]
            INSTR_SRL  : result = rs1 >>  rs2[4:0];
            INSTR_SRA  : result = rs1 >>> rs2[4:0]; // TODO make sure this produces the correct result
            // This dynamic casting causes a segfault in iverilog, should probably create an issue
            // INSTR_SLT  : result = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0;
            INSTR_SLT  : result = ((rs1 < imm) ^ (rs1[31] != imm[31])) ? 32'b1 : 32'b0;
            INSTR_SLTU : result = rs1 < rs2 ? 32'b1 : 32'b0;
            default    : result = 32'b0;
        endcase
    end

    /* TODO Instructions that are not yet implemented
        // I-Type (Load)
        INSTR_LB,
        INSTR_LH,
        INSTR_LW,
        INSTR_LBU,
        INSTR_LHU,
        
        // S-Type (Store)
        INSTR_SB,
        INSTR_SH,
        INSTR_SW,
     */


endmodule
