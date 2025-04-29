`timescale 1ns / 1ps

module register_file(
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire        write_en,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
    );

    logic [31:0] registers [1:31];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (reset) begin
            for (integer i = 1; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (write_en && (rd_addr != 0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

    // Synchronous read
    always_ff @(posedge clk) begin
        if (reset) begin
            rs1_data <= 32'b0;
            rs2_data <= 32'b0;
        end else if(!stall) begin
            if (rs1_addr == 0) begin
                rs1_data <= 32'b0;
            end else begin
                rs1_data <= registers[rs1_addr];
            end

            if (rs2_addr == 0) begin
                rs2_data <= 32'b0;
            end else begin
                rs2_data <= registers[rs2_addr];
            end
        end
    end
    
endmodule
