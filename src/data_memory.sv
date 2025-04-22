`timescale 1ns / 1ps

// little-endian data memory
module data_memory
  #(parameter MEM_SIZE = 512) // memory size in bytes
   (input clk,
    input reset,
    input write_en,
    input [31:0] addr,
    input [ 1:0] store_size, // 00 = byte, 01 = half, 10 = word
    input [31:0] store_data,

    output [31:0] load_data
);

    // Memory
    reg [8:0] mem [0:MEM_SIZE];

    // Async Read
    assign load_data = reset ? 32'b0 : {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};

    // Synchronous Write
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < MEM_SIZE+1; i = i + 1) begin
                mem[i] = 32'b0;
            end
        end else if (write_en) begin
            if (store_size == 2'b00) begin // byte
                mem[addr] = store_data;
            end else if (store_size == 2'b01) begin // half word
                mem[addr] = store_data[7:0];
                mem[addr+1] = store_data[15:8];
            end else if (store_size == 2'b10) begin // word
                mem[addr] = store_data[7:0];
                mem[addr+1] = store_data[15:8];
                mem[addr+2] = store_data[23:16];
                mem[addr+3] = store_data[31:24];
            end

        end
    end
endmodule
