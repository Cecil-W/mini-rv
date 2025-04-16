`timescale 1ns / 1ps

import instruction_utils::*;

module decode(
    input [31:0] instr,
    
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output logic [31:0] imm,
    output wire rd_write_en,
    output rv32i_instr_e instr_type
    );
    
    wire is_r_type = instr[6:2] == 5'b01011 || instr[6:2] ==? 5'b011?0 || instr[6:2] == 5'b10100;
    wire is_i_type = (instr[6:5] == 2'b00 && (instr[4:2] ==? 3'b00? || instr[4:2] ==? 3'b1?0 )) || instr[6:2] == 5'b11001;
    wire is_s_type = instr[6:2] ==? 5'b0100?;
    wire is_b_type = instr[6:2] == 5'b11000;
    wire is_u_type = instr[6:2] ==? 5'b0?101;
    wire is_j_type = instr[6:2] == 5'b11011;
    
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    assign rd_write_en = is_r_type || is_i_type || is_u_type || is_j_type;

    // TODO I think the imm is wrong for the special I type cases, srai etc
    assign imm = is_i_type ? {{21{instr[31]}}, instr[30:20]} :
                 is_s_type ? {{21{instr[31]}}, instr[30:25], instr[11:7]} :
                 is_b_type ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} :
                 is_u_type ? {instr[31:12], 12'b0} :
                 is_j_type ? {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0} :
                 32'b0;

    always_comb begin // could move the imm assignment here
        case (opcode)
            OPCODE_BRANCH : begin
                case (funct3)
                    FUNCT3_BEQ  : instr_type = INSTR_BEQ;
                    FUNCT3_BNE  : instr_type = INSTR_BNE;
                    FUNCT3_BLT  : instr_type = INSTR_BLT;
                    FUNCT3_BGE  : instr_type = INSTR_BGE;
                    FUNCT3_BLTU : instr_type = INSTR_BLTU;
                    FUNCT3_BGEU : instr_type = INSTR_BGEU;
                    default     : instr_type = INSTR_ILLEGAL;
                endcase
            end
            OPCODE_LUI : begin
                instr_type = INSTR_LUI;
            end
            OPCODE_AUIPC : begin
                instr_type = INSTR_AUIPC;
            end
            OPCODE_JAL : begin
                instr_type = INSTR_JAL;
            end
            OPCODE_JALR : begin
                instr_type = INSTR_JALR;
            end
            OPCODE_LOAD : begin
                case (funct3)
                    FUNCT3_LB  : instr_type = INSTR_LB;
                    FUNCT3_LH  : instr_type = INSTR_LH;
                    FUNCT3_LW  : instr_type = INSTR_LW;
                    FUNCT3_LBU : instr_type = INSTR_LBU;
                    FUNCT3_LHU : instr_type = INSTR_LHU;
                    default    : instr_type = INSTR_ILLEGAL;
                endcase
            end
            OPCODE_STORE : begin
                case (funct3)
                    FUNCT3_SB : instr_type = INSTR_SB;
                    FUNCT3_SH : instr_type = INSTR_SH;
                    FUNCT3_SW : instr_type = INSTR_SW;
                    default   : instr_type = INSTR_ILLEGAL;
                endcase
            end
            OPCODE_OP_IMM : begin
                case (funct3)
                    FUNCT3_ADDI  : instr_type = INSTR_ADDI;
                    FUNCT3_SLTI  : instr_type = INSTR_SLTI;
                    FUNCT3_SLTIU : instr_type = INSTR_SLTIU;
                    FUNCT3_XORI  : instr_type = INSTR_XORI;
                    FUNCT3_ORI   : instr_type = INSTR_ORI;
                    FUNCT3_ANDI  : instr_type = INSTR_ANDI;
                    FUNCT3_SLLI  : instr_type = INSTR_SLLI;
                    FUNCT3_SRLI_SRAI : begin
                        case (funct7)
                            SHTYP_SRLI : instr_type = INSTR_SRLI;
                            SHTYP_SRAI : instr_type = INSTR_SRAI;
                            default    : instr_type = INSTR_ILLEGAL;
                        endcase
                    end                    
                    default : instr_type = INSTR_ILLEGAL;
                endcase
            end
            OPCODE_OP : begin
                case ({funct7, funct3})
                    {FUNCT7_ADD, FUNCT3_ADD_SUB} : instr_type = INSTR_ADD;
                    {FUNCT7_SUB, FUNCT3_ADD_SUB} : instr_type = INSTR_SUB;
                    {FUNCT7_SLL, FUNCT3_SLL}     : instr_type = INSTR_SLL;
                    {FUNCT7_SLT, FUNCT3_SLT}     : instr_type = INSTR_SLT;
                    {FUNCT7_SLTU, FUNCT3_SLTU}   : instr_type = INSTR_SLTU;
                    {FUNCT7_XOR, FUNCT3_XOR}     : instr_type = INSTR_XOR;
                    {FUNCT7_SRL, FUNCT3_SRL_SRA} : instr_type = INSTR_SRL;
                    {FUNCT7_SRA, FUNCT3_SRL_SRA} : instr_type = INSTR_SRA;
                    {FUNCT7_OR, FUNCT3_OR}       : instr_type = INSTR_OR;
                    {FUNCT7_AND, FUNCT3_AND}     : instr_type = INSTR_AND;
                    default : instr_type = INSTR_ILLEGAL;
                endcase
            end
            default : instr_type = INSTR_ILLEGAL;
        endcase        
    end
    
    
endmodule
