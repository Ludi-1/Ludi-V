module stage_writeback (
    // input wire clk,

    input wire [4:0] mem_rd,
    output wire [4:0] wb_rd,
    input wire mem_to_reg,
    input wire [31:0] mem_alu_result,
    input wire [31:0] mem_read_data,
    output reg [31:0] wb_write_data,
    input wire mem_wr_enable,
    output reg wb_wr_enable
);

assign wb_write_data = mem_to_reg ? mem_read_data : mem_alu_result;
assign wb_rd = mem_rd;
assign wb_wr_enable = mem_wr_enable;

endmodule