`timescale 1ns / 1ps

module decode(
    input [31:0] instr,
    
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output logic [31:0] imm,
    output wire rd_valid,
    output wire is_addi,
    output wire is_add,
    output wire is_beq,
    output wire is_bne,
    output wire is_blt,
    output wire is_bge,
    output wire is_bltu,
    output wire is_bgeu
    );
    
    wire is_r_type = instr[6:2] == 5'b01011 || instr[6:2] ==? 5'b011x0 || instr[6:2] == 5'b10100;
    wire is_i_type = (instr[6:5] == 2'b00 && (instr[4:2] ==? 3'b00x || instr[4:2] ==? 3'b1x0 )) || instr[6:2] == 5'b11001;
    wire is_s_type = instr[6:2] ==? 5'b0100x;
    wire is_b_type = instr[6:2] == 5'b11000;
    wire is_u_type = instr[6:2] ==? 5'b0x101;
    wire is_j_type = instr[6:2] == 5'b11011;
    
    wire [6:0] funct7 = instr[31:25];
    // wire [4:0] rs2 = instr[24:20];
    assign rs2 = instr[24:20];
    // wire [4:0] rs1 = instr[19:15];
    assign rs1 = instr[19:15];
    wire [2:0] funct3 = instr[14:12];
    // wire [4:0] rd = instr[11:7];
    assign rd = instr[11:7];
    wire [6:0] opcode = instr[6:0];

    wire funct7_valid = is_r_type;
    wire funct3_valid = is_r_type || is_i_type || is_s_type || is_b_type;
    wire rs1_valid = is_r_type || is_i_type || is_s_type || is_b_type;
    wire rs2_valid = is_r_type || is_s_type || is_b_type;
    assign rd_valid = is_r_type || is_i_type || is_u_type || is_j_type;
    wire imm_valid = is_i_type || is_s_type || is_b_type || is_u_type || is_j_type;

    assign imm = is_i_type ? {{21{instr[31]}}, instr[30:20]} :
                 is_s_type ? {{21{instr[31]}}, instr[30:25], instr[11:7]} :
                 is_b_type ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} :
                 is_u_type ? {instr[31:12], 12'b0} :
                 is_j_type ? {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0} :
                 32'b0;

    assign is_beq  = opcode == 'b1100011 && funct3 == 'b000;
    assign is_bne  = opcode == 'b1100011 && funct3 == 'b001;
    assign is_blt  = opcode == 'b1100011 && funct3 == 'b100;
    assign is_bge  = opcode == 'b1100011 && funct3 == 'b101;
    assign is_bltu = opcode == 'b1100011 && funct3 == 'b110;
    assign is_bgeu = opcode == 'b1100011 && funct3 == 'b111;

    assign is_addi = opcode == 'b0010011 && funct3 == 'b000;
    assign is_add  = opcode == 'b0110011 && funct3 == 'b000 && funct7 == 'b000_0000;
    
endmodule
