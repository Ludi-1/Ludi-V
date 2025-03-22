module led #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (
  axi_intf.slave axi,
  output logic [3:0] led
);

assign axi.awready = 1;
assign axi.wready = 1;
assign axi.bvalid = 1;
assign axi.arready = 1;

assign axi.bresp = 0;
assign axi.bvalid = 0;
assign axi.rdata = {28'b0, led};
assign axi.rresp = 0;
assign axi.rvalid = 1;

always_ff @(posedge axi.aclk) begin
  if (axi.aresetn) begin
    led = 4'b0000;
  end else if (axi.wready && axi.awready && axi.wvalid && axi.awvalid) begin
    if (axi.awaddr == 32'h00_00_00_FF) begin
      led = axi.wdata[3:0];
    end
  end
end

endmodule
