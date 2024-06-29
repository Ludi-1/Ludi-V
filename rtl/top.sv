module top (
    input wire clk,
    input wire rst
);

wire execute_pc_src, execute_jal_src, flush_fetch;
wire [31:0] fetch_instr_addr_plus,
            branch_instr_addr,
            jal_instr_addr,
            jalr_instr_addr,
            fetch_instr_addr,
            fetch_instr;
assign flush_fetch = execute_pc_src;
stage_fetch fetch (
    .clk(clk),
    .rst(rst),
    .pc_src(execute_pc_src),
    .jal_src(execute_jal_src),
    .jalr_instr_addr(jalr_instr_addr),
    .jal_instr_addr(jal_instr_addr),
    .flush_fetch(flush_fetch),
    .fetch_instr_addr_plus(fetch_instr_addr_plus),
    .branch_instr_addr(branch_instr_addr),
    .fetch_instr_addr(fetch_instr_addr),
    .fetch_instr(fetch_instr)
);

wire [31:0] rs_data1, rs_data2, decode_imm;
wire [4:0] decode_rd;
wire [3:0] decode_alu_ctrl;
wire [31:0] decode_instr_addr, decode_instr_addr_plus;

wire decode_jump, decode_jal_src, decode_branch, decode_wr_enable, decode_alu_src, wb_wr_enable, flush_decode;
wire [1:0] decode_result_src;
wire [31:0] wb_write_data;
wire [4:0] wb_rd;
wire [4:0] decode_shamt;
assign flush_decode = execute_pc_src;

stage_decode decode (
    .clk(clk),
    .rst(rst),
    .flush(flush_decode),
    .fetch_instr_addr(fetch_instr_addr),
    .fetch_instr_addr_plus(fetch_instr_addr_plus),
    .instr(fetch_instr),
    .decode_instr_addr(decode_instr_addr),
    .decode_instr_addr_plus(decode_instr_addr_plus),
    .decode_jump(decode_jump),
    .decode_jal_src(decode_jal_src),
    .decode_branch(decode_branch),
    .rs_data1(rs_data1),
    .rs_data2(rs_data2),
    .decode_rd(decode_rd),
    .decode_alu_ctrl(decode_alu_ctrl),
    .decode_shamt(decode_shamt),
    .decode_imm(decode_imm),
    .decode_alu_src(decode_alu_src),
    .decode_wr_enable(decode_wr_enable),
    .decode_result_src(decode_result_src),
    .wb_wr_addr(wb_rd),
    .wb_wr_data(wb_write_data),
    .wb_wr_enable(wb_wr_enable)
);

wire [31:0] execute_instr_addr_plus, execute_alu_result, execute_next_instr_addr;
wire [4:0] execute_rd;
wire execute_branch, execute_wr_enable;
wire [1:0] execute_result_src;

stage_execute execute (
    .clk(clk),
    .decode_rd(decode_rd),
    .decode_jump(decode_jump),
    .decode_jal_src(decode_jal_src),
    .decode_branch(decode_branch),
    .decode_instr_addr(decode_instr_addr),
    .decode_instr_addr_plus(decode_instr_addr_plus),
    .decode_alu_src(decode_alu_src),
    .decode_imm(decode_imm),
    .rs_data1(rs_data1),
    .rs_data2(rs_data2),
    .decode_wr_enable(decode_wr_enable),
    .decode_result_src(decode_result_src),
    .execute_rd(execute_rd),
    .shamt(decode_shamt),
    .alu_ctrl(decode_alu_ctrl),

    .execute_jal_src(execute_jal_src),
    .execute_pc_src(execute_pc_src),
    .execute_branch(execute_branch),
    .jal_instr_addr(jal_instr_addr),
    .jalr_instr_addr(jalr_instr_addr),
    .execute_next_instr_addr(execute_next_instr_addr),
    .execute_instr_addr_plus(execute_instr_addr_plus),
    .execute_alu_result(execute_alu_result),
    .execute_wr_enable(execute_wr_enable),
    .execute_result_src(execute_result_src)
);

wire [4:0] mem_rd;
wire [31:0] mem_read_data, mem_alu_result, mem_instr_addr_plus;
wire mem_wr_enable;
wire [1:0] mem_result_src;

stage_memory mem (
    .clk(clk),
    .execute_rd(execute_rd),
    .mem_rd(mem_rd),
    .execute_instr_addr_plus(execute_instr_addr_plus),
    .mem_instr_addr_plus(mem_instr_addr_plus),
    .execute_alu_result(execute_alu_result),
    .mem_alu_result(mem_alu_result),
    .execute_wr_enable(execute_wr_enable),
    .execute_result_src(execute_result_src),
    .mem_wr_enable(mem_wr_enable),
    .mem_result_src(mem_result_src)
);

stage_writeback wb (
    .clk(clk),
    .mem_rd(mem_rd),
    .wb_rd(wb_rd),
    .mem_instr_addr_plus(mem_instr_addr_plus),
    .mem_result_src(mem_result_src),
    .mem_alu_result(mem_alu_result),
    .mem_read_data(mem_read_data),
    .wb_write_data(wb_write_data),
    .mem_wr_enable(mem_wr_enable),
    .wb_wr_enable(wb_wr_enable)
);


endmodule