import instruction_utils::*;

// load and store unit, split accross the execute and writeback stage, address gets computed in the alu
module lsu(
    input clk,
    input rst,
    input stall,
    input logic [31:0] rs2,
    input rv32i_instr_e ex_instr_type,
    input logic [31:0] load_data, // wb stage

    output logic mem_wb_en, // setting the register file target to store mem output instead of alu result
    output logic [31:0] mem_wb, // wb stage
    output logic read_en,
    output logic write_en, // write enable for store instructions
    output logic [ 1:0] store_size, // 00 = byte, 01 = half, 10 = word
    output logic [31:0] store_data
);

    // constant select signals for the always_comb blocks to avoid iverilog errors
    wire [7:0] load_data_b = load_data[7:0];
    wire load_data_b_msb = load_data[7];
    wire [15:0] load_data_h = load_data[15:0];
    wire load_data_h_msb = load_data[15];
    wire [7:0] rs2_b = rs2[7:0];
    wire [15:0] rs2_h = rs2[15:0];

    // buffering the instruction type from execute stage to write back stage
    rv32i_instr_e wb_instr_type;
    always_ff @(posedge clk) begin
        if (rst) begin
            wb_instr_type = INSTR_NOP;
        end else if (!stall) begin
            wb_instr_type = ex_instr_type;
        end
    end

    // execute stage
    always_comb begin
        // defaults
        read_en = 0;
        write_en = 0;
        store_size = 2'b00;
        store_data = 32'b0;
        case (ex_instr_type)
            // I-Type (Load), only need to set read_en, address comes from the alu in execute_stage.sv
            INSTR_LB,
            INSTR_LH,
            INSTR_LW,
            INSTR_LBU,
            INSTR_LHU : read_en = 1;
            
            // S-Type (Store)
            INSTR_SB : begin
                write_en   = 1;
                store_size = 2'b00;
                store_data = rs2_b;
            end
            INSTR_SH : begin
                write_en   = 1;
                store_size = 2'b01;
                store_data = rs2_h;
            end
            INSTR_SW : begin
                write_en   = 1;
                store_size = 2'b10;
                store_data = rs2;
            end
            default : begin
                
                write_en = 0;
                read_en = 0;
                store_size = 2'b10;
                store_data = 32'b0;
            end
        endcase
    end

    // write back stage
    always_comb begin
        mem_wb_en = 0;
        mem_wb = 32'b0;
        case (wb_instr_type)
            INSTR_LB : begin
                mem_wb_en = 1;
                mem_wb = {{24{load_data_b_msb}}, load_data_b};
            end
            INSTR_LH : begin
                mem_wb_en = 1;                
                mem_wb = {{16{load_data_h_msb}}, load_data_h};
            end
            INSTR_LW : begin
                mem_wb_en = 1;
                mem_wb = load_data;
            end
            INSTR_LBU :begin
                mem_wb_en = 1;
                mem_wb = {{24{1'b0}}, load_data_b};
            end
            INSTR_LHU : begin
                mem_wb_en = 1;
                mem_wb = {{16{1'b0}}, load_data_h};
            end
            default : begin
                mem_wb_en = 0;
                mem_wb = 32'b0;
            end
        endcase        
    end    
endmodule


