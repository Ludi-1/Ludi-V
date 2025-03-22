module data_mem (
  axi_intf.slave axi
);

localparam ADDR_WIDTH = 7;

logic [7:0] data_memory0 [2**ADDR_WIDTH-2-1:0];
logic [7:0] data_memory1 [2**ADDR_WIDTH-1:0];
logic [7:0] data_memory2 [2**ADDR_WIDTH-1:0];
logic [7:0] data_memory3 [2**ADDR_WIDTH-1:0];


logic [7:0] read_data [3:0];

assign axi.awready = 1;
assign axi.wready = 1;
assign axi.rvalid = 1;
assign axi.arready = 1;

always_ff @(posedge axi.aclk) begin
  if (axi.awvalid && axi.wvalid) begin
    if (axi.wstrb[0]) data_memory0[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[7:0];
    if (axi.wstrb[1]) data_memory1[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[15:8];
    if (axi.wstrb[2]) data_memory2[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[23:16];
    if (axi.wstrb[3]) data_memory3[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[31:24];
  end
end

always_comb begin
  read_data[0] = data_memory0[axi.araddr[ADDR_WIDTH+2-1:2]];
  read_data[1] = data_memory1[axi.araddr[ADDR_WIDTH+2-1:2]];
  read_data[2] = data_memory2[axi.araddr[ADDR_WIDTH+2-1:2]];
  read_data[3] = data_memory3[axi.araddr[ADDR_WIDTH+2-1:2]];
  axi.rdata = {read_data[3], read_data[2], read_data[1], read_data[0]};
end

endmodule
