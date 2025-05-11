import instruction_utils::*;

module core_top(
    input wire clk,
    input wire rst
);

    // Instruction Fetch Stage

    wire ex_if_take_branch;
    wire [31:0] ex_if_branch_target;
    wire [31:0] if_id_instr_data;
    wire [31:0] if_id_pc;
    wire stall_if;

    fetch_stage if_stage (
        .clk(clk),
        .rst(rst),
        .stall(stall_if),
        .ex_if_branch_taken(ex_if_take_branch),
        .ex_if_branch_target(ex_if_branch_target),

        .if_id_instr_data(if_id_instr_data),
        .if_id_pc(if_id_pc)
    );

    // Instruction Decode Stage

    wire id_stall;
    wire wb_id_write_en;
    wire [ 4:0] wb_id_rd_addr;
    wire [31:0] wb_id_rd_data;

    wire rv32i_instr_e id_ex_instr_type;
    wire [ 4:0] id_ex_rs1_addr;
    wire [31:0] id_ex_rs1_data;
    wire [ 4:0] id_ex_rs2_addr;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_imm;
    wire [31:0] id_ex_pc;
    wire [ 4:0] id_ex_rd_addr;
    wire id_ex_write_en;

    decode_stage id_stage (
        .clk(clk),
        .rst(rst),
        .stall(id_stall),
        .if_id_instr_data(if_id_instr_data),
        .if_id_pc(if_id_pc),
        .wb_id_wr_en(wb_id_write_en),
        .wb_id_rd_addr(wb_id_rd_addr),
        .wb_id_rd_data(wb_id_rd_data),

        .id_ex_instr_type(id_ex_instr_type),
        .id_ex_rs1_addr(id_ex_rs1_addr),
        .id_ex_rs1_data(id_ex_rs1_data),
        .id_ex_rs2_addr(id_ex_rs2_addr),
        .id_ex_rs2_data(id_ex_rs2_data),
        .id_ex_imm(id_ex_imm),
        .id_ex_pc(id_ex_pc),
        .id_ex_rd_addr(id_ex_rd_addr),
        .id_ex_write_en(id_ex_write_en),
        .stall_if(stall_if)
    );

    // Execute & Write Back Stage
    // as the LSU goes across these two stages and the WB stage is trivial, they are combined here

    // Execute/alu wires
    wire ex_stall;
    wire [31:0] ex_wb_result;
    wire [31:0] mem_addr;

    // LSU wires
    wire [31:0] mem_wb_load_data;
    wire wb_lsu_write_sel;
    wire [31:0] wb_load_result;
    wire mem_read_en;
    wire mem_write_en;
    wire [ 1:0] store_size;
    wire [31:0] store_data;

    // write back to register file
    assign wb_id_rd_data = wb_lsu_write_sel ? wb_load_result : ex_wb_result;

    // Forwarding
    wire logic [31:0] ex_fwd_rs1_data;
    wire logic [31:0] ex_fwd_rs2_data;
    assign ex_fwd_rs1_data = (id_ex_rs1_addr == wb_id_rd_addr && wb_id_rd_addr != 32'b0) ? wb_id_rd_data : id_ex_rs1_data;
    assign ex_fwd_rs2_data = (id_ex_rs2_addr == wb_id_rd_addr && wb_id_rd_addr != 32'b0) ? wb_id_rd_data : id_ex_rs2_data;

    execute_stage ex_stage (
        .clk(clk),
        .rst(rst),
        .stall(ex_stall),
        .id_ex_instr_type(id_ex_instr_type),
        .ex_fwd_rs1_data(ex_fwd_rs1_data),
        .ex_fwd_rs2_data(ex_fwd_rs2_data),
        .id_ex_imm(id_ex_imm),
        .id_ex_pc(id_ex_pc),
        .id_ex_rd_addr(id_ex_rd_addr),
        .id_ex_write_en(id_ex_write_en),

        .ex_if_take_branch(ex_if_take_branch),
        .ex_if_branch_target(ex_if_branch_target),
        .ex_wb_result(ex_wb_result),
        .ex_wb_write_en(wb_id_write_en),
        .ex_wb_rd_addr(wb_id_rd_addr),
        .mem_addr(mem_addr)
    );
    
    lsu lsu (
        .clk(clk),
        .rst(rst),
        .stall(ex_stall),
        .id_ex_rs2_data(ex_fwd_rs2_data),
        .id_ex_instr_type(id_ex_instr_type),
        .mem_wb_load_data(mem_wb_load_data),

        .wb_lsu_write_sel(wb_lsu_write_sel),
        .wb_load_result(wb_load_result),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .store_size(store_size),
        .store_data(store_data)
    );
    
    data_memory #(
        .MEM_SIZE(64)
    ) d_mem (
        .clk(clk),
        .rst(rst),
        .write_en(mem_write_en),
        .read_en(mem_read_en),
        .addr(mem_addr),
        .store_size(store_size),
        .write_data(store_data),
        .read_data(mem_wb_load_data)
    );
endmodule
