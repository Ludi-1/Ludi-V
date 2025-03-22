module stage_writeback (
    input logic clk,
    input logic [4:0] mem_rd,
    output logic [4:0] wb_rd,
    input logic [1:0] mem_result_src,
    input logic [31:0] mem_alu_result,
    input logic [31:0] mem_read_data,
    output logic [31:0] wb_write_data,
    input logic [31:0] mem_instr_addr_plus,
    input logic mem_regfile_wr_enable,
    output logic wb_regfile_wr_enable
);

localparam [1:0]ALU_RESULT = 2'b00,
                MEM_TO_REG = 2'b01,
                   PC_PLUS = 2'b10,
                LUI_AUIPC  = 2'b11;

always_ff @(posedge clk) begin
// always_comb begin
    case (mem_result_src)
        ALU_RESULT | LUI_AUIPC: wb_write_data <= mem_alu_result;
                    MEM_TO_REG: wb_write_data <= mem_read_data;
                    PC_PLUS:    wb_write_data <= mem_instr_addr_plus;
                    default:    wb_write_data <= mem_alu_result;
    endcase
    wb_rd <= mem_rd;
    wb_regfile_wr_enable <= mem_regfile_wr_enable;
end

endmodule
