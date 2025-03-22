module stage_memory (
  axi_intf.master axi,

  // RD passthrough
  input logic [4:0] execute_rd,
  output logic [4:0] mem_rd,
  
  // WB passback
  input logic [4:0] wb_rd,
  input logic [31:0] wb_write_data,

  // Register file write enable passthrough
  input logic execute_regfile_wr_enable,
  output logic mem_regfile_wr_enable,

  // ALU result (passthrough)
  input logic [31:0] execute_alu_result,
  output logic [31:0] mem_alu_result,

  // PC + 4 passthrough
  input logic [31:0] execute_instr_addr_plus,
  output logic [31:0] mem_instr_addr_plus,

  // ResultSrc (ALU/datamem/PCplus) passthrough
  input logic [1:0] execute_result_src,
  output logic [1:0] mem_result_src,
  input logic execute_datamem_wr_enable,
  input logic [2:0] execute_funct3,
  input logic [31:0] execute_wr_datamem_data,
  output logic [31:0] mem_rd_datamem_data
);

logic [31:0] datamem_data, data_mem_addr, data_mem_addr_q;
logic execute_datamem_wr_enable_q, execute_regfile_wr_enable_q;

assign data_mem_addr = execute_alu_result;
assign datamem_data = execute_wr_datamem_data;
assign axi.wdata = datamem_data;
assign axi.awaddr = execute_alu_result;
assign axi.araddr = data_mem_addr;
assign axi.wvalid = execute_datamem_wr_enable;
assign axi.awvalid = execute_datamem_wr_enable;

/*
localparam NUM_SLAVES = 2;

axi_interconnect #(
  .NUM_SLAVES(NUM_SLAVES)
) axi_interconnect_inst (
  .axi_master(axi_intf_mem_stage.slave),
  .axi_slave0(axi_intf_data_mem.master),
  .axi_slave1(axi),
  .select(data_mem_addr == 32'h00_00_00_FF)
);

data_mem #(
) data_mem_inst (
  .axi(axi_intf_data_mem.slave)
);
*/

always_ff @(posedge axi.aclk) begin
  execute_datamem_wr_enable_q <= execute_datamem_wr_enable;
  data_mem_addr_q <= data_mem_addr;

  case (execute_funct3[1:0])
    2'b01: axi.wstrb = 4'b0011; // sh
    2'b10:  axi.wstrb = 4'b1111; // sw
    default: axi.wstrb = 4'b0001; // sb
  endcase
  if (execute_datamem_wr_enable_q && (data_mem_addr == data_mem_addr_q)) begin
    mem_rd_datamem_data <= wb_write_data;
  end else begin
    case (execute_funct3)
      3'b000: mem_rd_datamem_data <= {{24{axi.rdata[7]}}, axi.rdata[7:0]};
      3'b001: mem_rd_datamem_data <= {{16{axi.rdata[15]}}, axi.rdata[15:0]};
      3'b100: mem_rd_datamem_data <= {24'b0, axi.rdata[7:0]};
      3'b101: mem_rd_datamem_data <= {16'b0, axi.rdata[15:0]};
      default: mem_rd_datamem_data <= axi.rdata; // including 3'b010
    endcase
  end
  mem_alu_result <= execute_alu_result;
  mem_rd <= execute_rd;
  mem_regfile_wr_enable <= execute_regfile_wr_enable;
  mem_instr_addr_plus <= execute_instr_addr_plus;
  mem_result_src <= execute_result_src;
end

endmodule
