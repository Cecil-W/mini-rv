`timescale 1ns / 1ps

module tb_pc;
    reg reset = 1;
    reg stall = 0;
    reg clk = 0;
    reg [31:0] branch_target = 0;
    reg take_branch = 0;
    
    wire [31:0] counter;
    
    
    program_counter pc(.clk(clk),
        .reset(reset),              
        .stall(stall),              
        .branch_target(branch_target), 
        .branch_taken(take_branch),
        .pc(counter)
        );
    
    always #5 clk = ~clk;
    

    initial begin
        $monitor ("pc=%0b", counter);
        #6 reset <= 0;
        
        #10 stall <= 1;
        #10 stall <= 0;
        #5 branch_target = 'b1100;
        take_branch = 1;
        #5 take_branch = 0;
        
        #100 $finish;
    end
endmodule
