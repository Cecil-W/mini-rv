module fetch_stage(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic ex_if_branch_taken,
    input logic [31:0] ex_if_branch_target,

    output wire logic [31:0] if_id_instr_data,
    output logic [31:0] if_id_pc
);

    wire [31:0] pc;
    logic [31:0] next_pc;

    assign pc = ex_if_branch_taken ? ex_if_branch_target : next_pc;

    always_ff @(posedge clk) begin
        if (rst) begin
            if_id_pc <= 0;
            next_pc <= 0;
        end else if (!stall) begin
            if_id_pc <= pc;
            next_pc <= pc + 4;
        end
    end

    instruction_memory #(.MEM_SIZE(64)) i_mem(
        .clk(clk),
        .reset(rst),
        .stall(stall),
        .addr(pc),

        .data(if_id_instr_data)
    );
endmodule
