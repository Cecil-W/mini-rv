`timescale 1ns / 1ps

import instruction_utils::*;


// I could integrate this into the ALU
module comperator(
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input rv32i_instr_e instr,

    output logic take_branch
    );

    always_comb begin
        case (instr)
            INSTR_BEQ  : take_branch = rs1 == rs2;
            INSTR_BNE  : take_branch = rs1 != rs2;
            INSTR_BLT  : take_branch = (rs1 < rs2) ^ (rs1[31] != rs2[31]);
            INSTR_BGE  : take_branch = (rs1 >= rs2) ^ (rs1[31] != rs2[31]);
            INSTR_BLTU : take_branch = rs1 < rs2;
            INSTR_BGEU : take_branch = rs1 >= rs2;
            default    : take_branch = 1'b0;
        endcase
    end
endmodule



