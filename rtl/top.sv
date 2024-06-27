module top (
    input wire clk,
    input wire rst
);

wire branch;
wire [31:0] branch_instr_addr;
wire [31:0] fetch_instr_addr;
wire [31:0] fetch_instr;

stage_fetch fetch (
    .clk(clk),
    .rst(rst),
    .branch(branch),
    .branch_instr_addr(branch_instr_addr),
    .instr_addr(fetch_instr_addr),
    .instr(fetch_instr)
);

wire [31:0] rs_data1, rs_data2;
wire [4:0] decode_rd;
wire [3:0] decode_alu_ctrl;
wire [31:0] decode_instr_addr;

wire decode_wr_enable, decode_mem_to_reg, wb_wr_enable;
wire [31:0] wb_write_data;
wire [4:0] wb_rd;
wire [4:0] decode_shamt;

stage_decode decode (
    .clk(clk),
    .rst(rst),
    .fetch_instr_addr(fetch_instr_addr),
    .decode_instr_addr(decode_instr_addr),
    .instr(fetch_instr),
    .rs_data1(rs_data1),
    .rs_data2(rs_data2),
    .decode_rd(decode_rd),
    .decode_alu_ctrl(decode_alu_ctrl),
    .decode_shamt(decode_shamt),
    .decode_wr_enable(decode_wr_enable),
    .decode_mem_to_reg(decode_mem_to_reg),
    .wb_wr_addr(wb_rd),
    .wb_wr_data(wb_write_data),
    .wb_wr_enable(wb_wr_enable)
);

wire [31:0] execute_alu_result, execute_next_instr_addr;
wire [4:0] execute_rd;
wire execute_wr_enable, execute_mem_to_reg;

stage_execute execute (
    .clk(clk),
    .decode_rd(decode_rd),
    .execute_rd(execute_rd),
    .decode_instr_addr(decode_instr_addr),
    .execute_next_instr_addr(execute_next_instr_addr),
    .rs_data1(rs_data1),
    .rs_data2(rs_data2),
    .shamt(decode_shamt),
    .alu_ctrl(decode_alu_ctrl),
    .execute_alu_result(execute_alu_result),
    .decode_wr_enable(decode_wr_enable),
    .decode_mem_to_reg(decode_mem_to_reg),
    .execute_wr_enable(execute_wr_enable),
    .execute_mem_to_reg(execute_mem_to_reg)
);

wire [4:0] mem_rd;
wire [31:0] mem_read_data, mem_alu_result;
wire mem_wr_enable, mem_mem_to_reg;

stage_memory mem (
    .clk(clk),
    .execute_rd(execute_rd),
    .mem_rd(mem_rd),
    .execute_alu_result(execute_alu_result),
    .mem_alu_result(mem_alu_result),
    .execute_wr_enable(execute_wr_enable),
    .execute_mem_to_reg(execute_mem_to_reg),
    .mem_wr_enable(mem_wr_enable),
    .mem_mem_to_reg(mem_mem_to_reg)
);

stage_writeback wb (
    // .clk(clk),
    .mem_rd(mem_rd),
    .wb_rd(wb_rd),
    .mem_to_reg(mem_mem_to_reg),
    .mem_alu_result(mem_alu_result),
    .mem_read_data(mem_read_data),
    .wb_write_data(wb_write_data),
    .mem_wr_enable(mem_wr_enable),
    .wb_wr_enable(wb_wr_enable)
);


endmodule