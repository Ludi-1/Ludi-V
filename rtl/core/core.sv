module core #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (
  axi_intf.master axi
    /*input logic clk,
    input logic rstn,

    output logic [ADDR_WIDTH-1:0] awaddr,
    output logic awvalid,
    input logic awready,
    output logic [DATA_WIDTH-1:0] wdata,
    output logic [(DATA_WIDTH/8)-1:0] wstrb,
    output logic wvalid,
    input logic wready,
    input logic bvalid,
    input logic bready,

    output logic [ADDR_WIDTH-1:0] araddr,
    output logic arvalid,
    input logic arready,
    input logic [DATA_WIDTH-1:0] rdata,
    input logic rvalid,
    output logic rready*/
);

wire execute_pc_src, execute_jal_src, flush_fetch;
wire [31:0] fetch_instr_addr_plus,
            jal_instr_addr,
            jalr_instr_addr,
            fetch_instr_addr,
            fetch_instr;
assign flush_fetch = execute_pc_src;
stage_fetch fetch (
  .clk(axi.aclk),
  .rstn(axi.aresetn),
  .pc_src(execute_pc_src),
  .jal_src(execute_jal_src),
  .jalr_instr_addr(jalr_instr_addr),
  .jal_instr_addr(jal_instr_addr),
  .flush_fetch(flush_fetch),
  .fetch_instr_addr_plus(fetch_instr_addr_plus),
  .fetch_instr_addr(fetch_instr_addr),
  .fetch_instr(fetch_instr)
);

wire [31:0] decode_rs_data1, decode_rs_data2, decode_imm;
wire [4:0] decode_rd, wb_rd, decode_rs1, decode_rs2;
wire [1:0] decode_alu_op;
wire [2:0] decode_funct3, execute_funct3;
wire decode_funct7b5;
wire [31:0] decode_instr_addr, decode_instr_addr_plus;

wire decode_jump, decode_jal_src, decode_branch, decode_regfile_wr_enable, decode_alu_src, decode_lui_auipc, wb_regfile_wr_enable, flush_decode;
wire [31:0] wb_write_data;
assign flush_decode = decode_jump;

wire decode_datamem_wr_enable, execute_datamem_wr_enable;
wire [1:0] decode_result_src, execute_result_src;

wire [4:0] mem_rd;
wire [31:0] mem_rd_datamem_data, mem_alu_result, mem_instr_addr_plus;
wire mem_regfile_wr_enable;
wire [1:0] mem_result_src;

wire [31:0] execute_instr_addr_plus, execute_alu_result;
wire [4:0] execute_rd;
wire execute_regfile_wr_enable;
wire [31:0] execute_wr_datamem_data;

stage_decode decode (
  .clk(axi.aclk),
  .rstn(axi.aresetn),
  .flush(flush_decode),

  .instr(fetch_instr),
  .fetch_instr_addr(fetch_instr_addr),
  .fetch_instr_addr_plus(fetch_instr_addr_plus),

  .decode_instr_addr(decode_instr_addr),
  .decode_instr_addr_plus(decode_instr_addr_plus),

  .rs_data1(decode_rs_data1),
  .rs_data2(decode_rs_data2),

  .decode_datamem_wr_enable(decode_datamem_wr_enable),

  .decode_rd(decode_rd),
  .decode_rs1(decode_rs1),
  .decode_rs2(decode_rs2),

  .decode_alu_op(decode_alu_op),
  .decode_funct3(decode_funct3),
  .decode_funct7b5(decode_funct7b5),
  .decode_imm(decode_imm),

  .decode_jump(decode_jump),
  .decode_jal_src(decode_jal_src),
  .decode_branch(decode_branch),

  .decode_alu_src(decode_alu_src),
  .decode_lui_auipc(decode_lui_auipc),

  .decode_regfile_wr_enable(decode_regfile_wr_enable),
  .decode_result_src(decode_result_src),
  .wb_wr_addr(wb_rd),
  .wb_wr_data(wb_write_data),
  .wb_regfile_wr_enable(wb_regfile_wr_enable)
);

stage_execute execute (
  .clk(axi.aclk),

  .decode_rd(decode_rd),
  .execute_rd(execute_rd),

  .decode_rs1(decode_rs1),
  .decode_rs2(decode_rs2),
  .wb_rd(wb_rd),
  .mem_rd(mem_rd),
  .wb_write_data(wb_write_data),
  .mem_alu_result(mem_alu_result),
  .mem_regfile_wr_enable(mem_regfile_wr_enable),
  .wb_regfile_wr_enable(wb_regfile_wr_enable),
  .mem_result_src(mem_result_src),
  .mem_read_data(mem_rd_datamem_data),

  .execute_pc_src(execute_pc_src),

  .decode_jump(decode_jump),
  .decode_jal_src(decode_jal_src),
  .execute_jal_src(execute_jal_src),

  .jal_instr_addr(jal_instr_addr),
  .jalr_instr_addr(jalr_instr_addr),
  .decode_instr_addr(decode_instr_addr),

  .decode_instr_addr_plus(decode_instr_addr_plus),
  .execute_instr_addr_plus(execute_instr_addr_plus),

  .decode_branch(decode_branch),

  .decode_alu_src(decode_alu_src),
  .decode_imm(decode_imm),

  .rs_data1(decode_rs_data1),
  .rs_data2(decode_rs_data2),

  .decode_alu_op(decode_alu_op),
  .decode_funct3(decode_funct3),
  .decode_funct7b5(decode_funct7b5),

  .execute_funct3(execute_funct3),
  .decode_lui_auipc(decode_lui_auipc),

  .decode_regfile_wr_enable(decode_regfile_wr_enable),
  .execute_regfile_wr_enable(execute_regfile_wr_enable),

  .decode_datamem_wr_enable(decode_datamem_wr_enable),
  .decode_result_src(decode_result_src),
  .execute_datamem_wr_enable(execute_datamem_wr_enable),
  .execute_result_src(execute_result_src),

  .execute_wr_datamem_data(execute_wr_datamem_data),
  .execute_alu_result(execute_alu_result)
);

stage_memory mem (
  .axi(axi),

  .execute_rd(execute_rd),
  .mem_rd(mem_rd),

  .wb_rd(wb_rd),
  .wb_write_data(wb_write_data),

  .execute_regfile_wr_enable(execute_regfile_wr_enable),
  .mem_regfile_wr_enable(mem_regfile_wr_enable),

  .execute_alu_result(execute_alu_result),
  .mem_alu_result(mem_alu_result),

  .execute_instr_addr_plus(execute_instr_addr_plus),
  .mem_instr_addr_plus(mem_instr_addr_plus),

  .execute_result_src(execute_result_src),
  .mem_result_src(mem_result_src),

  .execute_datamem_wr_enable(execute_datamem_wr_enable),
  .execute_funct3(execute_funct3),
  .execute_wr_datamem_data(execute_wr_datamem_data),
  .mem_rd_datamem_data(mem_rd_datamem_data)
);

stage_writeback wb (
  .clk(axi.aclk),
  .mem_rd(mem_rd),
  .wb_rd(wb_rd),
  .mem_instr_addr_plus(mem_instr_addr_plus),
  .mem_result_src(mem_result_src),
  .mem_alu_result(mem_alu_result),
  .mem_read_data(mem_rd_datamem_data),
  .wb_write_data(wb_write_data),
  .mem_regfile_wr_enable(mem_regfile_wr_enable),
  .wb_regfile_wr_enable(wb_regfile_wr_enable)
);

endmodule
