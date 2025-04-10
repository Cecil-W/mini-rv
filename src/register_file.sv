`timescale 1ns / 1ps

module register_file(
    input  wire        clk,
    input  wire        reset,
    input  wire        write_en,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
    );

    reg [31:0] registers [1:31];

    assign rs1_data = (rs1_addr == 0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 32'b0 : registers[rs2_addr];
    
    // Synchronous write (on rising clock edge)
    always_ff @(posedge clk) begin
        if (reset) begin
            for (integer i = 1; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (write_en && (rd_addr != 0)) begin
            // Write to register (skip x0)
            registers[rd_addr] <= rd_data;
        end
    end
endmodule
