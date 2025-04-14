`timescale 1ns / 1ps

import instruction_utils::*;

module alu(
    input logic [31:0] operand1,
    input logic [31:0] operand2,
    input logic [31:0] imm,
    input logic [31:0] pc,

    input rv32i_instr_e instr,

    output logic [31:0] result
);
    
    always_comb begin
        case (instr)
            // U-Type
            INSTR_AUIPC : result = pc + imm;
            INSTR_LUI   : result = imm;
            // I-Type (ALU Immediate)
            INSTR_ADDI  : result = operand1 + imm;
            INSTR_XORI  : result = operand1 ^ imm;
            INSTR_ORI   : result = operand1 | imm;
            INSTR_ANDI  : result = operand1 & imm;
            // This dynamic casting causes a segfault in iverilog
            // INSTR_SLTI  : result = ($signed'(operand1) < $signed'(imm)) ? 32'b1 : 32'b0;
            INSTR_SLTI  : result = ((operand1 < imm) ^ (operand1[31] != imm[31])) ? 32'b1 : 32'b0;
            INSTR_SLTIU : result = operand1 < imm ? 32'b1 : 32'b0;
            INSTR_SLLI  : result = operand1 << imm[4:0];
            INSTR_SRLI  : result = operand1 >> imm[4:0];
            INSTR_SRAI  : result = operand1 >>> imm[4:0];
            
            // R-Type (Register-Register ALU)
            INSTR_ADD  : result = operand1 + operand2;
            INSTR_SUB  : result = operand1 - operand2;
            INSTR_XOR  : result = operand1 ^ operand2;
            INSTR_OR   : result = operand1 | operand2;
            INSTR_AND  : result = operand1 & operand2;
            INSTR_SLL  : result = operand1 <<  operand2[4:0]; // on rv64 shift by rs2[5:0]
            INSTR_SRL  : result = operand1 >>  operand2[4:0];
            INSTR_SRA  : result = operand1 >>> operand2[4:0]; // TODO make sure this produces the correct result
            // This dynamic casting causes a segfault in iverilog, should probably create an issue
            // INSTR_SLT  : result = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0;
            INSTR_SLT  : result = ((operand1 < imm) ^ (operand1[31] != imm[31])) ? 32'b1 : 32'b0;
            INSTR_SLTU : result = operand1 < operand2 ? 32'b1 : 32'b0;
            default    : result = 32'b0;
        endcase
    end
    
    /* TODO Instructions that are not yet implemented
        // I-Type
        INSTR_JALR,
        
        // J-Type
        INSTR_JAL,
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
