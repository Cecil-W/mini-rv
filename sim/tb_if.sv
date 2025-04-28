// Testbench for the instruction_fetch module
`timescale 1ns / 1ps

module tb_if;
    parameter CLK_PERIOD = 10; // Clock period in ns
    logic clk = 0;
    logic rst;
    logic stall;
    logic take_branch;
    logic [31:0] branch_address;
    logic [31:0] instr;

    fetch_stage dut (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .take_branch(take_branch),
        .branch_address(branch_address),
        .instr(instr)
    );

    always #(CLK_PERIOD/2) clk <= !clk;

    // Test sequence
    initial begin
        $display("Starting Testbench for instruction_fetch");
        // 1. Initialize signals and apply reset
        rst <= 1'b1;
        stall <= 1'b0;
        take_branch <= 1'b0;
        branch_address <= 32'h0000_0000;
        $display("[%0t] Asserting Reset", $time);
        @(negedge clk); // Hold reset for 2 cycles

        // 2. De-assert reset and run normally
        rst <= 1'b0;
        $display("[%0t] De-asserting Reset", $time);
        // loading instructions into I memory just as a test case
        $readmemh("./sim/instr_test.hex", dut.i_memory_instance.mem, 0);
        @(posedge clk);
        $display("[%0t] Normal operation starts", $time);
        repeat (5) @(posedge clk); // Run for 5 cycles

        // 3. Test stall condition
        stall <= 1'b1;
        $display("[%0t] Asserting Stall", $time);
        repeat (3) @(posedge clk);
        stall <= 1'b0;
        $display("[%0t] De-asserting Stall", $time);
        @(posedge clk);
        repeat (2) @(posedge clk);
        
        // 4. Test branch taken condition
        branch_address <= 32'h000000A0;
        take_branch <= 1'b1;
        @(posedge clk);
        $display("[%0t] Asserting take_branch to address %h", $time, branch_address);
        take_branch <= 1'b0;
        branch_address <= 32'h0000_0000;
        $display("[%0t] De-asserting take_branch", $time);
        repeat (5) @(posedge clk); // Run for 5 cycles after branch

        // 5. Test branch not taken (just run normally)
        $display("[%0t] Running normally (branch not taken)", $time);
        take_branch <= 1'b0;
        branch_address <= 32'h0000_2000; // Provide an address, but don't assert take_branch
        repeat (5) @(posedge clk);

        // 6. End simulation
        $display("[%0t] Test sequence finished", $time);
        $finish;
    end

    // Optional: Monitor signals for debugging
    initial begin
        $monitor("stall=%b, take_branch=%b, branch_addr=%h, pc=%08h instr=%08h",
            stall, take_branch, branch_address, dut.pc, instr);
        $dumpfile("sim/tb_if.fst");
        $dumpvars(0,tb_if);
    end

endmodule : tb_if
