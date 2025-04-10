`timescale 1ns / 1ns

module program_counter(
    input clk,
    input reset,                // Active-high reset
    input stall,                // When high, PC doesn't update NOTE: not in use until i implement a pipeline
    input [31:0] branch_target, // Branch/jump target address
    input branch_taken,         // Control signal indicating branch/jump is taken
    
    output reg [31:0] pc        // Current program counter value
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= 0;
        end else if (!stall) begin
            pc <= branch_taken ? branch_target : pc + 4;            
        end
    end
endmodule
