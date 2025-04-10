`timescale 1ns / 1ps

module comperator(
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire is_beq,
    input  wire is_bne,
    input  wire is_blt,
    input  wire is_bge,
    input  wire is_bltu,
    input  wire is_bgeu,

    output wire take_branch
    );

    assign take_branch = is_beq ? rs1 == rs2 :
                         is_bne ? rs1 != rs2 :
                         is_blt ? (rs1 < rs2) ^ (rs1[31] != rs2[31]) :
                         is_bge ? (rs1 >= rs2) ^ (rs1[31] != rs2[31]) :
                         is_bltu ? rs1 < rs2 :
                         is_bgeu ? rs1 >= rs2 :
                         'b0;
        
endmodule



