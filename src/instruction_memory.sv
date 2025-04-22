`timescale 1ns / 1ps

module instruction_memory(
    // input clk, // currently as i use a asynchronous read and its ROM 
    input reset,
    input [31:0] addr,

    output [31:0] data
);
    
    // Memory should be byte addressable but for now i'll leave it as is and just divide the addr/4
    reg [31:0] mem [0:63];
    
    // for now i just divide the memory by
    assign data = reset ? 32'b0 : mem[addr/4];
endmodule
