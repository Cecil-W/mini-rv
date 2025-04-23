`timescale 1ns / 1ps

import instruction_utils::*;

module tb_core;

    // Clock and reset signals
    logic clk = 0;
    logic reset;

    // Instantiate the DUT
    core_top dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Reset the core
        reset = 1;
        #7 reset = 0;

        $display("Starting test sequence...");

        // Monitor execution
        if ($test$plusargs("debug")) begin
            forever @(posedge clk) begin
                if (!reset) begin
                    $display("PC: 0x%08h | Instr: 0x%08h | %s \t| rs1=%0d | rs2=%0d",
                        dut.pc, dut.instr, instruction_utils::disassemble(dut.instr), dut.rs1_data, dut.rs2_data);
                    if (dut.reg_file.write_en && dut.rd != 0) begin
                        $display("    Register Write: x%0d = %0d", dut.rd, dut.alu_result);
                    end
                end
            end
        end else $display("set +debug to print debug information");
    end

    // Test program
    initial begin
        if ($test$plusargs("sum_test")) begin
            // Initialize instruction memory with test program
            // Program calculates sum of numbers from 5 down to 1 (5+4+3+2+1 = 15)
            $readmemh("./sim/sum_test.hex", dut.i_mem.mem, 0);

            // Wait for completion
            #500;

            // Check final register values
            if(dut.reg_file.registers[1] == 0 && dut.reg_file.registers[2] == 15) begin
                $display("TEST PASSED: x1 = 0, x2 = 15 as expected");
            end else begin
                $display("TEST FAILED: x1 = %0d (expected 0), x2 = %0d (expected 15)", dut.reg_file.registers[1], dut.reg_file.registers[2]);
            end
        end
        if ($test$plusargs("instr_test")) begin
            // this program tests every instruction (except for b and h load/store instructions)
            // each innstruction test should result in a 1 in the respective register (x5-x29)
            $readmemh("./sim/instr_test.hex", dut.i_mem.mem, 0);
            // Wait for completion
            #800;
            for (int i = 5; i < 30; i = i + 1) begin
                if(dut.reg_file.registers[i] != 1) begin
                    $display("Register x%0d failed!", i);
                end
            end
            $display("TEST DONE");
        end

        $finish;
    end

    initial begin
        if ($test$plusargs("dump")) begin
            $dumpfile("tb_core.fst");
            $dumpvars(0,tb_core);
        end
    end

    // Timeout
    initial begin
        #1000;
        $display("TEST TIMEOUT");
        $finish;
    end

endmodule

