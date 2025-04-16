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
                        $display("    Register Write: x%0d = %0d", dut.rd, dut.result);
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
            // 0: addi x1, x0, 5      // x1 = 5 (counter)
            // 4: addi x2, x0, 0      // x2 = 0 (sum)
            // 8: loop:
            // 8: add x2, x2, x1      // sum += counter
            // c: addi x1, x1, -1     // counter--
            //10: bne x1, x0, -8      // loop if counter != 0 (jump to 8)
            //14: addi x0, x0, 0      // loop exit; nop
            //18: beq x0, x0, -4      // infinit loop to not crash the simulation

            // reading the instructions from a file, this behaves differntly in vivado and iverilog
            // vivado fills the buffer from 0 upwards, and iverilog seems to fill from top to bottom
            // therefore i can leave the memory oversized in vivado but not for iverilog
            $readmemh("./sim/sum_test.txt", dut.i_mem.mem, 0);

            // Wait for completion
            #500;
            
            // Check final register values
            if(dut.reg_file.registers[1] == 0 && dut.reg_file.registers[2] == 15) begin
                $display("TEST PASSED: x1 = 0, x2 = 15 as expected");
            end else begin
                $display("TEST FAILED: x1 = %0d (expected 0), x2 = %0d (expected 15)", dut.reg_file.registers[1], dut.reg_file.registers[2]);
            end
        end
        if ($test$plusargs("alu_test")) begin
            // this program should test every instruction(except for load/store as they are not implemented yet)
            // each innstruction test should result in a 1 in the respective register (x5-x30)
            $readmemh("./sim/alu_test.hex", dut.i_mem.mem, 0);
            // Wait for completion
            #800;
            for (int i = 5; i < 31; i = i + 1) begin
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

