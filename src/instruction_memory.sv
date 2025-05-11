`timescale 1ns / 1ps

module instruction_memory
  #(parameter MEM_SIZE = 256)
   (input logic clk,
    input logic reset,
    input wire logic stall,
    input logic [31:0] addr,

    output logic [31:0] data
);

    // Memory, will remain big endian non byte adressable, as otherwise loading a program is annoying
    logic [31:0] mem [0:MEM_SIZE-1];

    // write
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < MEM_SIZE; i = i + 1) begin
                mem[i] = 32'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            data <= 32'h00000013;
        end else if (stall) begin
            data <= 32'h00000013; // NOP
        end else begin
            data <= mem[addr>>2];
        end
    end
    
endmodule
