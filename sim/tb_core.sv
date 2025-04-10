`timescale 1ns / 1ps
`include "core_top.sv"

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

    
    // Instruction disassembler
    function automatic string disassemble(input logic [31:0] instr);
        logic [6:0] opcode = instr[6:0];
        logic [4:0] rd = instr[11:7];
        logic [2:0] funct3 = instr[14:12];
        logic [4:0] rs1 = instr[19:15];
        logic [4:0] rs2 = instr[24:20];
        logic [6:0] funct7 = instr[31:25];
        logic [11:0] imm_i = instr[31:20];
        logic [11:0] imm_b = {instr[31], instr[7], instr[30:25], instr[11:8]};

        string result_str;

        case (opcode)
            // I-type
            7'b0010011: begin
                case (funct3)
                    3'b000: result_str = $sformatf("addi x%0d, x%0d, %0d", rd, rs1, $signed(imm_i));
                    default: result_str = "unknown I-type";
                endcase
            end
            // R-type
            7'b0110011: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            result_str = $sformatf("add x%0d, x%0d, x%0d", rd, rs1, rs2);
                        else
                            result_str = "unknown R-type";
                    end
                    default: result_str = "unknown R-type";
                endcase
            end
            // B-type
            7'b1100011: begin
                case (funct3)
                    3'b000: result_str = $sformatf("beq x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    3'b001: result_str = $sformatf("bne x%0d, x%0d, pc%0d", rs1, rs2, $signed({imm_b, 1'b0}));
                    default: result_str = "unknown B-type";
                endcase
            end
            default: result_str = "unknown instruction";
        endcase
        return result_str;
    endfunction

    // Test sequence
    initial begin
        // Reset the core
        reset = 1;
        #7 reset = 0;

        $display("Starting test sequence...");

        // Monitor execution
        forever @(posedge clk) begin
            if (!reset) begin
                $display("PC: 0x%08h | Instr: 0x%08h | %s", 
                        dut.pc, dut.instr, disassemble(dut.instr));
                
                // Display source register values when relevant
                if (dut.is_addi || dut.is_add || dut.is_beq || dut.is_bne) begin
                    $display("    x%0d = 0x%08h (%0d), x%0d = 0x%08h (%0d)",
                            dut.rs1, dut.rs1_data, dut.rs1_data,
                            dut.rs2, dut.rs2_data, dut.rs2_data);
                end
                if (dut.reg_file.write_en && dut.rd != 0) begin
                    $display("    Register Write: x%0d = 0x%08h (%0d)", dut.rd, dut.result, dut.result);
                end
            end
        end
    end

    // Test program
    initial begin
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

        // Program in hex if the readmemh task isn't supported
        // dut.i_mem.mem[0] = 32'h00500093; // addi x1, x0, 5
        // dut.i_mem.mem[1] = 32'h00000113; // addi x2, x0, 0
        // dut.i_mem.mem[2] = 32'h00110133; // add x2, x2, x1
        // dut.i_mem.mem[3] = 32'hfff08093; // addi x1, x1, -1
        // dut.i_mem.mem[4] = 32'hfe009ce3; // bne x1, x0, -8 (relative to next PC)
        // dut.i_mem.mem[5] = 32'h00000013; // nop (addi x0, x0, 0)
        // dut.i_mem.mem[6] = 32'hfe000ee3; // beq x0, x0, -4

        // reading the instructions from a file, this behaves differntly in vivado and iverilog
        // vivado fills the buffer from 0 upwards, and iverilog seems to fill from top to bottom
        $readmemh("./sum_test.txt", dut.i_mem.mem, 0);

        // Wait for completion
        #500;
        
        // Check final register values
        assert(dut.reg_file.registers[1] == 0 && dut.reg_file.registers[2] == 15) begin
            $display("TEST PASSED: x1 = 0, x2 = 15 as expected");
        end else begin
            $display("TEST FAILED: x1 = %0d (expected 0), x2 = %0d (expected 15)", dut.reg_file.registers[1], dut.reg_file.registers[2]);
        end
        $finish;
    end

    // initial begin
    //     $dumpfile("test.fst");
    //     $dumpvars(0,tb_core);
    // end

    // Timeout
    initial begin
        #1000;
        $display("TEST TIMEOUT");
        $finish;
    end

endmodule