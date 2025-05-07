import instruction_utils::*;

module alu(
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [31:0] imm,
    input wire [31:0] pc,
    input rv32i_instr_e instr,

    output logic take_branch,
    output logic [31:0] branch_target,
    output logic [31:0] result
);

    // iverilog error: sorry: constant selects in always_* processes are not currently supported (all bits will be included).
    // wires for the constant selects
    wire [4:0] shift_imm = imm[4:0]; // on rv64 shift by 6 bits, but on rv32 the shift is only 5 bits
    wire rs1_msb = rs1[31];
    wire rs2_msb = rs2[31];
    wire imm_msb = imm[31];
    wire [4:0] shift_rs2 = rs2[4:0]; // on rv64 shift by rs2[5:0]
    wire [63:0] sext_rs1_64 = {{32{rs1[31]}}, rs1};

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
                branch_target = (rs1 + imm) & {{31{1'b1}}, 1'b0};
            end
            // U-Type
            INSTR_AUIPC : result = pc + imm;
            INSTR_LUI   : result = imm;
            // B-Type
            INSTR_BEQ  : take_branch = rs1 == rs2;
            INSTR_BNE  : take_branch = rs1 != rs2;
            INSTR_BLT  : take_branch = (rs1 < rs2) ^ (rs1_msb != rs2_msb);
            INSTR_BGE  : take_branch = (rs1 >= rs2) ^ (rs1_msb != rs2_msb);
            INSTR_BLTU : take_branch = rs1 < rs2;
            INSTR_BGEU : take_branch = rs1 >= rs2;
            // I-Type (ALU Immediate)
            INSTR_LHU,
            INSTR_LB,
            INSTR_LH,
            INSTR_LW,
            INSTR_LBU,
            INSTR_SB,
            INSTR_SH,
            INSTR_SW,
            INSTR_ADDI  : result = rs1 + imm; // reuse addi for load/store address computation
            INSTR_XORI  : result = rs1 ^ imm;
            INSTR_ORI   : result = rs1 | imm;
            INSTR_ANDI  : result = rs1 & imm;
            INSTR_SLTI  : result = {31'b0, ((rs1 < imm) ^ (rs1_msb != imm_msb))};
            INSTR_SLTIU : result = {31'b0, rs1 < imm};
            INSTR_SLLI  : result = rs1 << shift_imm;
            INSTR_SRLI  : result = rs1 >> shift_imm;
            INSTR_SRAI  : result = sext_rs1_64 >> shift_imm; // can't use >>> as the inputs are not signed

            // R-Type (Register-Register ALU)
            INSTR_ADD  : result = rs1 + rs2;
            INSTR_SUB  : result = rs1 - rs2;
            INSTR_XOR  : result = rs1 ^ rs2;
            INSTR_OR   : result = rs1 | rs2;
            INSTR_AND  : result = rs1 & rs2;
            INSTR_SLL  : result = rs1 <<  shift_rs2;
            INSTR_SRL  : result = rs1 >>  shift_rs2;
            INSTR_SRA  : result = sext_rs1_64 >> shift_rs2;
            INSTR_SLT  : result = {31'b0, ((rs1 < rs2) ^ (rs1_msb != imm_msb))};
            INSTR_SLTU : result = {31'b0, rs1 < rs2};
            default    : result = 32'b0;
        endcase
    end
endmodule
