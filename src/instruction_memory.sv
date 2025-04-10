`timescale 1ns / 1ps

module instruction_memory(
    // input clk, // currently i dont need a clk signal as the core is currently single cylce, and i just use a combinational read 
    input reset,
    input [31:0] addr,

    output [31:0] data
);
    
    // Memory should be byte addressable but for now i'll leave it as is and just divide the addr/4
    reg [31:0] mem [0:6];
    
    // for now i just divide the memory by
    assign data = reset ? 32'b0 : mem[addr/4];
endmodule
