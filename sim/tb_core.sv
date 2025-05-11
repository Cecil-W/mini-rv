`timescale 1ns / 1ps

import instruction_utils::*;

module tb_core;

    // Clock and reset signals
    localparam CLK_PERIOD = 10;    
    logic clk = 0;
    logic reset = 1;

    // Instantiate the DUT
    core_top dut (
        .clk(clk),
        .rst(reset)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    assign dut.if_stall = 0;
    assign dut.id_stall = 0;
    assign dut.ex_stall = 0;

    // reset
    initial begin
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
    end
    

    // Test sequence
    initial begin
        wait (reset == 0);
        @(posedge clk);
        
        $display("[%0t] Reset done.", $time);
        $display("Starting test sequence...");
        if ($test$plusargs("sum_test")) begin
            // Initialize instruction memory with test program
            // Program calculates sum of numbers from 5 down to 1 (5+4+3+2+1 = 15)
            $readmemh("./sim/sum_test.hex", dut.if_stage.i_mem.mem, 0);

            // Wait for completion
            #500;

            // Check final register values
            if(dut.id_stage.reg_file.registers[1] == 0 && dut.id_stage.reg_file.registers[2] == 15) begin
                $display("TEST PASSED: x1 = 0, x2 = 15 as expected");
            end else begin
                $display("TEST FAILED: x1 = %0d (expected 0), x2 = %0d (expected 15)",
                dut.id_stage.reg_file.registers[1], dut.id_stage.reg_file.registers[2]);
            end
        end else if ($test$plusargs("instr_test")) begin
            // this program tests every instruction (except for b and h load/store instructions)
            // each innstruction test should result in a 1 in the respective register (x5-x29)
            $readmemh("./sim/instr_test.hex", dut.if_stage.i_mem.mem, 0);
            // Wait for completion
            #800;
            for (int i = 5; i < 30; i = i + 1) begin
                assert(dut.id_stage.reg_file.registers[i] == 1) else $error("Instruction for register x%0d failed!", i);
            end
            $display("TEST DONE");
        end else begin
            $warning("No Program selected! Set either +sum_test or +instr_test");
        end

        $finish;
    end

    // Monitor execution
    initial begin        
        if ($test$plusargs("debug")) begin
            forever @(posedge clk) begin
                if (!reset) begin
                    $display("-----------------------------------------------------------------------------");
                    if (!dut.if_stall) begin
                        $display("  IF : PC=0x%8h", dut.if_stage.pc);
                    end else if (dut.ex_if_take_branch) begin
                        $display("  IF : Branch to PC=0x%8h", dut.if_stage.ex_if_branch_target);
                    end else begin
                        $display("  IF : ---- STALLED or EMPTY ----");
                    end

                    if (!dut.id_stall) begin
                        $display("  ID : PC=0x%8h, %s",
                            dut.if_id_pc, instruction_utils::disassemble(dut.if_id_instr_data));
                    end else begin
                        $display("  ID : ---- STALLED or EMPTY ----");
                    end

                    if (!dut.ex_stall) begin
                        $display("  EX : PC=0x%8h, %s, rs1=%0d, rs2=%0d, imm=%0d, ALU_Out=%0d",
                        dut.id_ex_pc, instruction_utils::name(dut.id_ex_instr_type), $signed(dut.ex_fwd_rs1_data), // TODO try to use dut.id_stage.id_ex_instr_type
                        $signed(dut.ex_fwd_rs2_data), $signed(dut.ex_stage.id_ex_imm), $signed(dut.ex_stage.ex_result));
                    end else begin
                        $display("  EX : ---- STALLED or EMPTY ----");
                    end

                    $display("  WB : Instr=%s, rd[%0d]=%0d, RegWrite=%b",
                        dut.lsu.wb_instr_type.name(), dut.wb_id_rd_addr, $signed(dut.wb_id_rd_data), dut.wb_id_write_en);
                end
            end
        end else $display("set +debug to print debug information");
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

