

module fetch_stage(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic take_branch,
    input logic [31:0] branch_address,

    output wire logic [31:0] instr
);

    wire [31:0] pc;
    

    program_counter pc_instance (
        .clk(clk),
        .reset(rst),
        .stall(stall),
        .branch_target(branch_address),
        .branch_taken(take_branch),

        .pc(pc)
    );


    instruction_memory #(.MEM_SIZE(64)) i_memory_instance(
        .clk(clk),
        .reset(rst),
        .addr(pc),

        .data(instr)
    );
endmodule
