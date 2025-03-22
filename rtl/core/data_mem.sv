module data_mem (
  axi_intf.slave axi
);

localparam ADDR_WIDTH = 14;


/*
logic [7:0] data_memory0 [2**ADDR_WIDTH-1:0];
logic [7:0] data_memory1 [2**ADDR_WIDTH-1:0];
logic [7:0] data_memory2 [2**ADDR_WIDTH-1:0];
logic [7:0] data_memory3 [2**ADDR_WIDTH-1:0];
*/

logic [7:0] read_data [3:0];
logic bram_we [4:0];

assign axi.awready = 1;
assign axi.wready = 1;
assign axi.rvalid = 1;
assign axi.arready = 1;

assign axi.bresp = 0;
assign axi.bvalid = 0;
assign axi.rresp = 0;

genvar i;
generate
  for (i = 0; i < 4; i++) begin: gen_bram
    bram #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(8)
    ) bram_inst (
      .clk(axi.aclk),
      .we(bram_we[i]),
      .addr(axi.awaddr[ADDR_WIDTH+2-1:2]),
      .din(axi.wdata[i*8 +: 8]),
      .dout(read_data[i])
    );
  end
endgenerate

always_ff @(posedge axi.aclk) begin
  for (int i = 0; i < 4; i++) begin
    if (axi.awvalid && axi.wvalid && axi.awready && axi.wready) begin
      bram_we[i] = axi.wstrb[i];
    end else begin
      bram_we[i] = 0;
    end
  end

    /*
    if (axi.wstrb[0]) data_memory0[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[7:0];
    if (axi.wstrb[1]) data_memory1[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[15:8];
    if (axi.wstrb[2]) data_memory2[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[23:16];
    if (axi.wstrb[3]) data_memory3[axi.awaddr[ADDR_WIDTH+2-1:2]] = axi.wdata[31:24];
    */
end

always_comb begin
  /*
  read_data[0] = data_memory0[axi.araddr[ADDR_WIDTH+2-1:2]];
  read_data[1] = data_memory1[axi.araddr[ADDR_WIDTH+2-1:2]];
  read_data[2] = data_memory2[axi.araddr[ADDR_WIDTH+2-1:2]];
  read_data[3] = data_memory3[axi.araddr[ADDR_WIDTH+2-1:2]];
  */
  axi.rdata = {read_data[3], read_data[2], read_data[1], read_data[0]};
end

endmodule
