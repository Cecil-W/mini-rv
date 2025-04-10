`timescale 1ns / 1ps

module alu(
    input  wire [31:0] operand1,
    input  wire [31:0] operand2,
    input  wire [31:0] imm,

    input  wire is_addi,
    input  wire is_add,

    output wire [31:0] result
);
    assign result = is_add  ? operand1 + operand2 :
                    is_addi ? operand1 + imm :
                    32'b0;
    
endmodule
