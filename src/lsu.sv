import instruction_utils::*;

// load and store unit, split accross the execute and writeback stage, address gets computed in the alu
module lsu(
    input clk,
    input rst,
    input stall,
    input logic [31:0] id_ex_rs2_data,
    input rv32i_instr_e id_ex_instr_type,
    input logic [31:0] mem_wb_load_data, // wb stage

    output logic wb_lsu_write_sel, // setting the register file target to store mem output instead of alu result
    output logic [31:0] wb_load_result, // wb stage
    output logic mem_read_en,
    output logic mem_write_en, // write enable for store instructions
    output logic [ 1:0] store_size, // 00 = byte, 01 = half, 10 = word
    output logic [31:0] store_data
);

    // constant select signals for the always_comb blocks to avoid iverilog errors
    wire [7:0] load_data_b = mem_wb_load_data[7:0];
    wire load_data_b_msb = mem_wb_load_data[7];
    wire [15:0] load_data_h = mem_wb_load_data[15:0];
    wire load_data_h_msb = mem_wb_load_data[15];
    wire [7:0] rs2_b = id_ex_rs2_data[7:0];
    wire [15:0] rs2_h = id_ex_rs2_data[15:0];

    // buffering the instruction type from execute stage to write back stage
    rv32i_instr_e wb_instr_type;
    always_ff @(posedge clk) begin
        if (rst) begin
            wb_instr_type = INSTR_NOP;
        end else if (!stall) begin
            wb_instr_type = id_ex_instr_type;
        end
    end

    // execute stage
    always_comb begin
        // defaults
        mem_read_en = 0;
        mem_write_en = 0;
        store_size = 2'b00;
        store_data = 32'b0;
        case (id_ex_instr_type)
            // I-Type (Load), only need to set read_en, address comes from the alu in execute_stage.sv
            INSTR_LB,
            INSTR_LH,
            INSTR_LW,
            INSTR_LBU,
            INSTR_LHU : mem_read_en = 1;
            
            // S-Type (Store)
            INSTR_SB : begin
                mem_write_en   = 1;
                store_size = 2'b00;
                store_data = rs2_b;
            end
            INSTR_SH : begin
                mem_write_en   = 1;
                store_size = 2'b01;
                store_data = rs2_h;
            end
            INSTR_SW : begin
                mem_write_en   = 1;
                store_size = 2'b10;
                store_data = id_ex_rs2_data;
            end
            default : begin
                
                mem_write_en = 0;
                mem_read_en = 0;
                store_size = 2'b10;
                store_data = 32'b0;
            end
        endcase
    end

    // write back stage
    always_comb begin
        wb_lsu_write_sel = 0;
        wb_load_result = 32'b0;
        case (wb_instr_type)
            INSTR_LB : begin
                wb_lsu_write_sel = 1;
                wb_load_result = {{24{load_data_b_msb}}, load_data_b};
            end
            INSTR_LH : begin
                wb_lsu_write_sel = 1;                
                wb_load_result = {{16{load_data_h_msb}}, load_data_h};
            end
            INSTR_LW : begin
                wb_lsu_write_sel = 1;
                wb_load_result = mem_wb_load_data;
            end
            INSTR_LBU :begin
                wb_lsu_write_sel = 1;
                wb_load_result = {{24{1'b0}}, load_data_b};
            end
            INSTR_LHU : begin
                wb_lsu_write_sel = 1;
                wb_load_result = {{16{1'b0}}, load_data_h};
            end
            default : begin
                wb_lsu_write_sel = 0;
                wb_load_result = 32'b0;
            end
        endcase        
    end    
endmodule


