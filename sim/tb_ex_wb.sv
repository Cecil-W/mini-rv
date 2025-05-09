import instruction_utils::*;

// Testbench module for the execute_stage
module tb_ex_wb;
    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in ns

    // Testbench signals
    logic clk;
    logic rst;
    logic stall;
    rv32i_instr_e id_ex_instr_type;
    logic [ 4:0] id_ex_rs1_addr;
    logic [31:0] id_ex_rs1;
    logic [ 4:0] id_ex_rs2_addr;
    logic [31:0] id_ex_rs2;
    logic [31:0] id_ex_imm;
    logic [31:0] id_ex_pc;
    logic [4:0] id_ex_rd_addr;
    logic id_ex_write_en;

    // DUT outputs (wires)
    wire logic ex_if_take_branch;
    wire logic [31:0] ex_if_branch_target;
    wire logic [31:0] ex_wb_result;
    wire logic ex_wb_write_en;
    wire logic [4:0] ex_wb_rd_addr;
    wire logic [31:0] mem_addr;

    execute_stage dut_ex (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .id_ex_instr_type(id_ex_instr_type),
        .id_ex_rs1_addr(id_ex_rs1_addr),
        .id_ex_rs1_data(id_ex_rs1),
        .id_ex_rs2_addr(id_ex_rs2_addr),
        .id_ex_rs2_data(id_ex_rs2),
        .id_ex_imm(id_ex_imm),
        .id_ex_pc(id_ex_pc),
        .id_ex_rd_addr(id_ex_rd_addr),
        .id_ex_write_en(id_ex_write_en),
        .wb_ex_rd_addr(0), // TODO add a testcase for forwarding
        .wb_ex_rd_data(0),

        .ex_if_take_branch(ex_if_take_branch),
        .ex_if_branch_target(ex_if_branch_target),
        .ex_wb_result(ex_wb_result),
        .ex_wb_write_en(ex_wb_write_en),
        .ex_wb_rd_addr(ex_wb_rd_addr),
        .mem_addr(mem_addr)
    );

    wire logic mem_wb_en;
    wire logic [31:0] mem_wb;
    wire logic read_en;
    wire logic write_en;
    wire logic [1:0] store_size;
    wire logic [31:0] store_data;
    wire logic [31:0] load_data;

    assign load_data = 32'd42;
    

    lsu dut_lsu (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .id_ex_rs2_data(id_ex_rs2),
        .id_ex_instr_type(id_ex_instr_type),
        .mem_wb_load_data(load_data),

        .wb_lsu_write_sel(mem_wb_en),
        .wb_load_result(mem_wb),
        .mem_read_en(read_en),
        .mem_write_en(write_en),
        .store_size(store_size),
        .store_data(store_data)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk <= !clk;

    // Task to apply inputs and wait for one clock cycle
    task apply_inputs (
        input rv32i_instr_e instr_type,
        input logic [31:0] rs1,
        input logic [31:0] rs2,
        input logic [31:0] imm,
        input logic [31:0] pc,
        input logic [4:0] rd_addr,
        input logic write_en,
        input logic stall_in = 1'b0 // Default no stall
    );
        id_ex_instr_type = instr_type;
        id_ex_rs1 = rs1;
        id_ex_rs2 = rs2;
        id_ex_imm = imm;
        id_ex_pc = pc;
        id_ex_rd_addr = rd_addr;
        id_ex_write_en = write_en;
        stall = stall_in;
        // @(posedge clk);
        $display("T=%0t: Applied Instr=%s, rs1=%0d, rs2=%0d, imm=%0d, pc=%08h, rd=%d, wr_en=%b, stall=%b",
                 $time, instr_type.name(), rs1, rs2, imm, pc, rd_addr, write_en, stall_in);
    endtask

    // Task to reset the DUT
    task reset_dut();
        rst = 1;
        clk = 0; // Initialize clock
        stall = 0; // Initialize stall
        // Initialize other inputs to known values
        id_ex_instr_type = INSTR_NOP;
        id_ex_rs1 = 32'b0;
        id_ex_rs2 = 32'b0;
        id_ex_imm = 32'b0;
        id_ex_pc = 32'b0;
        id_ex_rd_addr = 5'b0;
        id_ex_write_en = 1'b0;
        @(negedge clk);
        rst = 0;
        @(posedge clk); // Deassert reset synchronously
        $display("T=%0t: Reset Released", $time);
    endtask

    initial begin
        $dumpfile("sim/tb_ex.fst");
        $dumpvars(0, tb_ex_wb);
    end
    

    // Main stimulus block
    initial begin
        $display("Starting Testbench for execute_stage...");

        // 1. Apply Reset
        reset_dut();

        // 2. Test NOP (should pass through without effect)
        apply_inputs(INSTR_NOP, 32'h0, 32'h0, 32'h0, 32'h1000, 5'd0, 1'b0);
        @(posedge clk);
        #1;
        assert (ex_wb_rd_addr == 0) else $error("NOP result mismatch");

        // 3. Test ADDI
        apply_inputs(INSTR_ADDI, 32'd10, 32'b0, 32'd5, 32'h1004, 5'd1, 1'b1); // rd1 = 10 + 5 = 15
        @(posedge clk);
        #1;
        assert (ex_wb_result == 32'd15) else $error("ADDI result mismatch");

        // 4. Test ADD
        apply_inputs(INSTR_ADD, 32'd20, 32'd30, 32'b0, 32'h1008, 5'd2, 1'b1); // rd2 = 20 + 30 = 50
        @(posedge clk);
        #1;
        assert (ex_wb_result == 32'd50) else $error("ADD result mismatch");

        // 5. Test SUB
        apply_inputs(INSTR_SUB, 32'd100, 32'd40, 32'd10, 32'h100C, 5'd3, 1'b1); // rd3 = 100 - 40 = 60
        @(posedge clk);
        #1;
        assert (ex_wb_result == 32'd60) else $error("SUB result mismatch");

        // 6. Test BEQ (Branch Taken)
        apply_inputs(INSTR_BEQ, 32'd50, 32'd50, 32'h10, 32'h1010, 5'd0, 1'b0); // Branch if 50 == 50, target = PC + imm = 0x1010 + 16 = 0x1020
        @(posedge clk);
        #1;
        assert (ex_if_take_branch == 1'b1 && ex_if_branch_target == 32'h1020) else $error("BEQ Taken mismatch");

        // 7. Test BNE (Branch Not Taken)
        apply_inputs(INSTR_BNE, 32'd50, 32'd50, 32'd20, 32'h1014, 5'd0, 1'b0); // Branch if 50 != 50 (false)
        @(posedge clk);
        #1;
        assert (ex_if_take_branch == 1'b0) else $error("BNE Not Taken mismatch");

        // 8. Test Load instruction (LW) - Result is memory address and should be output on 'mem_addr' on the same cycle
        apply_inputs(INSTR_LW, 32'h2000, 32'b0, 32'h8, 32'h1018, 5'd4, 1'b1); // rd4 will eventually get mem[rs1+imm], EX stage calculates address = 0x2000 + 8 = 0x2008
        #1;
        assert (mem_addr == 32'h2008 && read_en == 1 && write_en == 0) else $error("LW EX missmatch");
        @(posedge clk);
        #1;
        assert (ex_wb_result == 32'h2008 && mem_wb == 32'd42) else $error("LW WB mismatch");

        // 9. Test Store instruction (SW) - Result is memory address
        apply_inputs(INSTR_SW, 32'hF0, 32'd99, 32'hF, 32'h101C, 5'd0, 1'b0); // Store rs2 (99) to mem[rs1+imm], EX stage calculates address = 0x3000 + 12 = 0x300C
        #1;
        assert (mem_addr == 32'hFF && read_en == 0 && write_en == 1 && store_data == 32'd99) else $error("SW address mismatch");
        @(posedge clk);
        #1;
        assert (ex_wb_result == 32'hFF && ex_wb_write_en == 1'b0) else $error("SW address/wen mismatch");

        // 10. Test with Stall
        apply_inputs(INSTR_ADDI, 32'd1, 32'b0, 32'd1, 32'h1020, 5'd5, 1'b1, 1'b1); // Apply inputs but stall
        @(posedge clk);
        #1;
        // Outputs should remain the same as the previous SW instruction because of stall
        assert (ex_wb_result == 32'hFF && ex_wb_write_en == 1'b0) else $error("Output changed while stalled");

        // Release stall - the ADDI should now propagate
        apply_inputs(INSTR_ADDI, 32'd1, 32'b0, 32'd1, 32'h1020, 5'd5, 1'b1, 1'b0); // Same inputs, stall released
        @(posedge clk);
        #1;
        assert (ex_wb_result == 32'd2 && ex_wb_write_en == 1'b1 && ex_wb_rd_addr == 5'd5) else $error("Stall release mismatch");

        // Add more test cases for other instructions (SLT, SLL, JAL, JALR, LUI, AUIPC, etc.)

        // Finish simulation
        repeat (5) @(posedge clk); // Wait a few more cycles
        $display("Testbench finished.");
        $finish;
    end

    // Optional: Monitor outputs on every clock cycle
    // always @(posedge clk) begin
    //     if (!rst) begin // Don't monitor during reset
    //         $display("T=%0t Monitor: Instr=%s, Result=0x%h, WEN=%b, RD=%d, Branch=%b, Target=0x%h, MemAddr=0x%h",
    //                  $time, id_ex_instr_type.name(), ex_wb_result, ex_wb_write_en, ex_wb_rd_addr, ex_if_take_branch, ex_if_branch_target, mem_addr);
    //     end
    // end

endmodule : tb_ex_wb
