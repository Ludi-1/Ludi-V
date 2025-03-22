module stage_memory (
  axi_intf.master axi,

  // RD passthrough
  input wire [4:0] execute_rd,
  output reg [4:0] mem_rd,
  
  // WB passback
  input logic [4:0] wb_rd,
  input logic [31:0] wb_write_data,

  // Register file write enable passthrough
  input wire execute_regfile_wr_enable,
  output reg mem_regfile_wr_enable,

  // ALU result (passthrough)
  input wire [31:0] execute_alu_result,
  output reg [31:0] mem_alu_result,

  // PC + 4 passthrough
  input wire [31:0] execute_instr_addr_plus,
  output reg [31:0] mem_instr_addr_plus,

  // ResultSrc (ALU/datamem/PCplus) passthrough
  input wire [1:0] execute_result_src,
  output reg [1:0] mem_result_src,
  input wire execute_datamem_wr_enable,
  input wire [2:0] execute_funct3,
  input wire [31:0] execute_wr_datamem_data,
  output reg [31:0] mem_rd_datamem_data
);

logic [7:0] data_memory [127:0]; // 128 B data mem
logic [31:0] datamem_data, data_mem_addr, data_mem_addr_q;
logic execute_datamem_wr_enable_q, execute_regfile_wr_enable_q;
logic [6:0] data_mem_addr_0, data_mem_addr_1, data_mem_addr_2, data_mem_addr_3; // log2(128)
assign data_mem_addr = execute_alu_result;
assign data_mem_addr_0 = data_mem_addr[6:0];
assign data_mem_addr_1 = data_mem_addr_0 + 1;
assign data_mem_addr_2 = data_mem_addr_0 + 2;
assign data_mem_addr_3 = data_mem_addr_0 + 3;
assign datamem_data = execute_wr_datamem_data;
// assign datamem_data = (execute_datamem_wr_enable_q && (data_mem_addr == data_mem_addr_q)) ? wb_write_data : execute_wr_datamem_data;
//assign datamem_data = ((execute_datamem_wr_enable_q && (data_mem_addr == data_mem_addr_q)) || (execute_regfile_wr_enable_q && (execute_rd == mem_rd))) ? wb_write_data : execute_wr_datamem_data;
assign axi.wdata = datamem_data;
assign axi.awaddr = execute_alu_result;

always_comb begin
    if (data_mem_addr == 32'h00_00_00_FF && execute_datamem_wr_enable) begin
      axi.wvalid = 1;
      axi.awvalid = 1;
    end else begin
      axi.wvalid = 0;
      axi.awvalid = 0;
    end
end

always_ff @(posedge axi.aclk) begin
  execute_datamem_wr_enable_q <= execute_datamem_wr_enable;
  data_mem_addr_q <= data_mem_addr;
  // execute_regfile_wr_enable_q <= execute_regfile_wr_enable;

  if (execute_datamem_wr_enable) begin
    case (execute_funct3[1:0])
      2'b01: begin // sh
        data_memory[data_mem_addr_0] <= datamem_data[7:0];
        data_memory[data_mem_addr_1] <= datamem_data[15:8];
        axi.wstrb = 4'b0011;
      end
      2'b10: begin // sw
        data_memory[data_mem_addr_0] <= datamem_data[7:0];
        data_memory[data_mem_addr_1] <= datamem_data[15:8];
        data_memory[data_mem_addr_2] <= datamem_data[23:16];
        data_memory[data_mem_addr_3] <= datamem_data[31:24];
        axi.wstrb = 4'b1111;
      end
      default: begin // sb
        data_memory[data_mem_addr_0] <= datamem_data[7:0];
        axi.wstrb = 4'b0001;
      end
    endcase

  end

  if (execute_datamem_wr_enable_q && (data_mem_addr == data_mem_addr_q)) begin
    mem_rd_datamem_data <= wb_write_data;
  end else begin
    case (execute_funct3)
      3'b000: mem_rd_datamem_data <= {{24{data_memory[data_mem_addr_0][7]}}, data_memory[data_mem_addr_0]};
      3'b001: mem_rd_datamem_data <= {{16{data_memory[data_mem_addr_1][7]}}, data_memory[data_mem_addr_1], data_memory[data_mem_addr_0]};
      3'b010: begin
        mem_rd_datamem_data <= {
          data_memory[data_mem_addr_3],
          data_memory[data_mem_addr_2],
          data_memory[data_mem_addr_1],
          data_memory[data_mem_addr_0]
        };
      end
      3'b100: begin
        mem_rd_datamem_data <= {24'b0, data_memory[data_mem_addr_0]}; // LBU
      end
      3'b101: begin
        mem_rd_datamem_data <= {16'b0, data_memory[data_mem_addr_1], data_memory[data_mem_addr_0]}; // LHU
      end
      default: begin
        mem_rd_datamem_data <= {
          data_memory[data_mem_addr_3],
          data_memory[data_mem_addr_2],
          data_memory[data_mem_addr_1],
          data_memory[data_mem_addr_0]
        };
      end
    endcase
  end
  mem_alu_result <= execute_alu_result;
  mem_rd <= execute_rd;
  mem_regfile_wr_enable <= execute_regfile_wr_enable;
  mem_instr_addr_plus <= execute_instr_addr_plus;
  mem_result_src <= execute_result_src;
end

/*
initial begin
    for (integer i = 0; i < 128; i = i + 1) $dumpvars(0, data_memory[i]);
end
*/


endmodule
