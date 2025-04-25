`timescale 1ns / 1ps

// little-endian data memory
module data_memory
  #(parameter MEM_SIZE = 512) // memory size in bytes
   (input clk,
    input reset,
    input write_en,
    input read_en,
    input [31:0] addr,
    input [ 1:0] store_size, // 00 = byte, 01 = half, 10 = word
    input [31:0] write_data,

    output logic [31:0] read_data
);

    // Memory
    logic [7:0] mem [0:MEM_SIZE-1];

    // Async Read, sign extention and byte selection is performed by the lsu
    assign read_data = (reset || !read_en) ? 32'b0 : {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};


    // Synchronous Write
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < MEM_SIZE; i = i + 1) begin
                mem[i] = 32'b0;
            end
        end else if (write_en) begin
            case (store_size)
                2'b00 : begin // byte
                    mem[addr] = write_data[7:0];
                end
                2'b01 : begin // half word
                    {mem[addr+1], mem[addr]} = write_data[15:0];
                end
                2'b10 : begin // word
                    {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} = write_data;
                end
                default : begin // default to byte write
                    mem[addr] = write_data[7:0];
                end
            endcase
        end
    end
endmodule
