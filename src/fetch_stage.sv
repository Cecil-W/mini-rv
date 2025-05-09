module fetch_stage(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic ex_if_take_branch,
    input logic [31:0] ex_if_branch_target,

    output wire logic [31:0] if_id_instr_data,
    output logic [31:0] if_id_pc
);

    wire [31:0] pc;

    always_ff @(posedge clk) begin
        if (rst) begin
            if_id_pc <= 0;
        end else if (!stall) begin
            if_id_pc <= pc;
        end
    end

    program_counter pc_instance (
        .clk(clk),
        .reset(rst),
        .stall(stall),
        .branch_target(ex_if_branch_target),
        .branch_taken(ex_if_take_branch),

        .pc(pc)
    );


    instruction_memory #(.MEM_SIZE(64)) i_memory_instance(
        .clk(clk),
        .reset(rst),
        .addr(pc),

        .data(if_id_instr_data)
    );
endmodule
