`timescale 1ns / 1ps

package instruction_utils;
    // RV32I instructions
    typedef enum logic [5:0]{
        // --- Instruction Types ---
        INSTR_ILLEGAL,
        INSTR_NOP, // addi x0, x0, 0

        // U-Type
        INSTR_LUI,
        INSTR_AUIPC,

        // J-Type
        INSTR_JAL,

        // I-Type (ALU Immediate)
        INSTR_JALR,
        INSTR_ADDI,
        INSTR_SLTI,
        INSTR_SLTIU,
        INSTR_XORI,
        INSTR_ORI,
        INSTR_ANDI,
        INSTR_SLLI,
        INSTR_SRLI,
        INSTR_SRAI,

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

        // B-Type (Branch)
        INSTR_BEQ,
        INSTR_BNE,
        INSTR_BLT,
        INSTR_BGE,
        INSTR_BLTU,
        INSTR_BGEU,

        // R-Type (Register-Register ALU)
        INSTR_ADD,
        INSTR_SUB,
        INSTR_SLL,
        INSTR_SLT,
        INSTR_SLTU,
        INSTR_XOR,
        INSTR_SRL,
        INSTR_SRA,
        INSTR_OR,
        INSTR_AND
    } rv32i_instr_e;

    // Opcodes (RV32I)
    localparam logic [6:0] OPCODE_BRANCH = 7'b110_0011; // B
    localparam logic [6:0] OPCODE_LUI    = 7'b011_0111; // U - no funct3
    localparam logic [6:0] OPCODE_AUIPC  = 7'b001_0111; // U - no funct3
    localparam logic [6:0] OPCODE_JAL    = 7'b110_1111; // J - no funct3
    localparam logic [6:0] OPCODE_JALR   = 7'b110_0111; // J - no funct3
    localparam logic [6:0] OPCODE_LOAD   = 7'b000_0011; // I
    localparam logic [6:0] OPCODE_STORE  = 7'b010_0011; // S
    localparam logic [6:0] OPCODE_OP_IMM = 7'b001_0011; // I Arith/Logic Immediate
    localparam logic [6:0] OPCODE_OP     = 7'b011_0011; // R Arith/Logic Register
    
    // Funct3 
    // Branch opcode
    localparam logic [2:0] FUNCT3_BEQ    = 3'b000;
    localparam logic [2:0] FUNCT3_BNE    = 3'b001;
    localparam logic [2:0] FUNCT3_BLT    = 3'b100;
    localparam logic [2:0] FUNCT3_BGE    = 3'b101;
    localparam logic [2:0] FUNCT3_BLTU   = 3'b110;
    localparam logic [2:0] FUNCT3_BGEU   = 3'b111;
    // Load opcode
    localparam logic [2:0] FUNCT3_LB     = 3'b000;
    localparam logic [2:0] FUNCT3_LH     = 3'b001;
    localparam logic [2:0] FUNCT3_LW     = 3'b010;
    localparam logic [2:0] FUNCT3_LBU    = 3'b100;
    localparam logic [2:0] FUNCT3_LHU    = 3'b101;
    // Store opcode
    localparam logic [2:0] FUNCT3_SB     = 3'b000;
    localparam logic [2:0] FUNCT3_SH     = 3'b001;
    localparam logic [2:0] FUNCT3_SW     = 3'b010;
    // ALU IMM OPCODE_OP_IMM 001_0011
    localparam logic [2:0] FUNCT3_ADDI   = 3'b000;
    localparam logic [2:0] FUNCT3_SLTI   = 3'b010;
    localparam logic [2:0] FUNCT3_SLTIU  = 3'b011;
    localparam logic [2:0] FUNCT3_XORI   = 3'b100;
    localparam logic [2:0] FUNCT3_ORI    = 3'b110;
    localparam logic [2:0] FUNCT3_ANDI   = 3'b111;
    // Shifts
    localparam logic [2:0] FUNCT3_SLLI      = 3'b001;
    localparam logic [2:0] FUNCT3_SRLI_SRAI = 3'b101;
    // Shift specialization
    localparam logic [6:0] SHTYP_SRLI     = 7'b0000_000;
    localparam logic [6:0] SHTYP_SRAI     = 7'b0100_000;
    // ALU 011_0011
    localparam logic [2:0] FUNCT3_ADD_SUB = 3'b000;
    localparam logic [2:0] FUNCT3_SLL     = 3'b001;
    localparam logic [2:0] FUNCT3_SLT     = 3'b010;
    localparam logic [2:0] FUNCT3_SLTU    = 3'b011;
    localparam logic [2:0] FUNCT3_XOR     = 3'b100;
    localparam logic [2:0] FUNCT3_SRL_SRA = 3'b101;
    localparam logic [2:0] FUNCT3_OR      = 3'b110;
    localparam logic [2:0] FUNCT3_AND     = 3'b111;
    
    // Funct7
    // funct3 000
    localparam logic [6:0] FUNCT7_ADD  = 7'b0000_000;
    localparam logic [6:0] FUNCT7_SUB  = 7'b0100_000;
    // funct3 001
    localparam logic [6:0] FUNCT7_SLL  = 7'b0000_000;
    // funct3 010
    localparam logic [6:0] FUNCT7_SLT  = 7'b0000_000;
    // funct3 011
    localparam logic [6:0] FUNCT7_SLTU = 7'b0000_000;
    // funct3 100
    localparam logic [6:0] FUNCT7_XOR  = 7'b0000_000;
    // funct3 101
    localparam logic [6:0] FUNCT7_SRL  = 7'b0000_000;
    localparam logic [6:0] FUNCT7_SRA  = 7'b0100_000;
    // funct3 110
    localparam logic [6:0] FUNCT7_OR   = 7'b0000_000;
    // funct3 111
    localparam logic [6:0] FUNCT7_AND  = 7'b0000_000;
    

    function automatic string disassemble(input logic [31:0] instr);
        logic [6:0] opcode = instr[6:0];
        logic [4:0] rd = instr[11:7];
        logic [2:0] funct3 = instr[14:12];
        logic [4:0] rs1 = instr[19:15];
        logic [4:0] rs2 = instr[24:20];
        logic [6:0] funct7 = instr[31:25];
        integer signed imm_i = {{21{instr[31]}}, instr[30:20]};
        integer signed imm_s = {{21{instr[31]}}, instr[30:25], instr[11:7]};
        integer signed imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        integer signed imm_u = {instr[31:12], 12'b0};
        integer signed imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

        string result_str;

        case (opcode)
            // I-type
            OPCODE_OP_IMM: begin
                case (funct3)
                    FUNCT3_ADDI  : begin
                        if (rs1 == 0 && rd == 0 && imm_i == 0) begin
                            result_str = "nop";
                        end else begin
                            result_str = $sformatf("addi x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                        end
                    end
                    FUNCT3_SLTI  : result_str = $sformatf("slti x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    FUNCT3_SLTIU : result_str = $sformatf("sltiu x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    FUNCT3_XORI  : result_str = $sformatf("xori x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    FUNCT3_ORI   : result_str = $sformatf("ori x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    FUNCT3_ANDI  : result_str = $sformatf("andi x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    FUNCT3_SLLI  : result_str = $sformatf("slli x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    FUNCT3_SRLI_SRAI : begin 
                        case (funct7)
                            SHTYP_SRLI : result_str = $sformatf("srli x%0d, x%0d, %0d", rd, rs1, $signed(rs2));
                            SHTYP_SRAI : result_str = $sformatf("srai x%0d, x%0d, %0d", rd, rs1, $signed(rs2));
                            default    : result_str = "unknown I-type";
                        endcase
                    end
                    default: result_str = "unknown I-type";
                endcase
            end
            // R-type
            OPCODE_OP : begin
                case ({funct7, funct3})
                    {FUNCT7_ADD, FUNCT3_ADD_SUB} : result_str = $sformatf("add x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_SUB, FUNCT3_ADD_SUB} : result_str = $sformatf("sub x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_SLL, FUNCT3_SLL}     : result_str = $sformatf("sll x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_SLT, FUNCT3_SLT}     : result_str = $sformatf("slt x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_SLTU, FUNCT3_SLTU}   : result_str = $sformatf("sltu x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_XOR, FUNCT3_XOR}     : result_str = $sformatf("xor x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_SRL, FUNCT3_SRL_SRA} : result_str = $sformatf("srl x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_SRA, FUNCT3_SRL_SRA} : result_str = $sformatf("sra x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_OR, FUNCT3_OR}       : result_str = $sformatf("or x%0d, x%0d, x%0d", rd, rs1, rs2);
                    {FUNCT7_AND, FUNCT3_AND}     : result_str = $sformatf("and x%0d, x%0d, x%0d", rd, rs1, rs2);
                    default : result_str = "unknown R-type";
                endcase
            end
            OPCODE_BRANCH : begin
                case (funct3)
                    FUNCT3_BEQ  : result_str = $sformatf("beq x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    FUNCT3_BNE  : result_str = $sformatf("bne x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    FUNCT3_BLT  : result_str = $sformatf("blt x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    FUNCT3_BGE  : result_str = $sformatf("bge x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    FUNCT3_BLTU : result_str = $sformatf("bltu x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    FUNCT3_BGEU : result_str = $sformatf("bgeu x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    default: result_str = "unknown B-type";
                endcase
            end
            OPCODE_LOAD : begin 
                case (funct3)
                    FUNCT3_LB  : result_str = $sformatf("lb x%0d, %0d(x%0d)", rd, imm_i, rs1);
                    FUNCT3_LH  : result_str = $sformatf("lh x%0d, %0d(x%0d)", rd, imm_i, rs1);
                    FUNCT3_LW  : result_str = $sformatf("lw x%0d, %0d(x%0d)", rd, imm_i, rs1);
                    FUNCT3_LBU : result_str = $sformatf("lbu x%0d, %0d(x%0d)", rd, imm_i, rs1);
                    FUNCT3_LHU : result_str = $sformatf("lhu x%0d, %0d(x%0d)", rd, imm_i, rs1);
                    default: result_str = "Ill-formed Load Instruction!";
                endcase
            end
            OPCODE_STORE : begin
                case (funct3)
                    FUNCT3_SB : result_str = $sformatf("sb x%0d, %0d(x%0d)", rs2, imm_s, rs1);
                    FUNCT3_SH : result_str = $sformatf("sh x%0d, %0d(x%0d)", rs2, imm_s, rs1);
                    FUNCT3_SW : result_str = $sformatf("sw x%0d, %0d(x%0d)", rs2, imm_s, rs1);
                    default   : result_str = "Ill-formed Store Instruction!";
                endcase
            end
            OPCODE_LUI   : result_str = $sformatf("lui x%0d, %0d", rd, imm_u);
            OPCODE_AUIPC : result_str = $sformatf("auipc x%0d, %0d", rd, imm_u[31:12]);
            OPCODE_JAL   : result_str = $sformatf("jal x%0d, %0d", rd, imm_j);
            OPCODE_JALR  : result_str = $sformatf("jalr x%0d, %0d(x%0d)", rd, imm_i, rs1);
            default: result_str = "unknown instruction";
        endcase
        return result_str;
    endfunction
endpackage : instruction_utils
