module axi_interconnect #(parameter NUM_SLAVES = 1) (
  axi_intf.slave axi_master,
  axi_intf.master axi_slave0,
  axi_intf.master axi_slave1,
  input logic [$clog2(NUM_SLAVES)-1:0] select
);

always_comb begin
  if (select) begin
    axi_slave1.awaddr = axi_master.awaddr;
    axi_slave1.awvalid = axi_master.awvalid;
    axi_slave1.wdata = axi_master.wdata;
    axi_slave1.wstrb = axi_master.wstrb;
    axi_slave1.wvalid = axi_master.wvalid;
    axi_slave1.araddr = axi_master.araddr;
    axi_slave1.arvalid = axi_master.arvalid;
    axi_slave1.rready = axi_master.rready;
    axi_master.awready = axi_slave1.awready;
    axi_master.wready = axi_slave1.wready;
    axi_master.rdata = axi_slave1.rdata;
    axi_master.rvalid = axi_slave1.rvalid;

    axi_slave0.awaddr = 0;
    axi_slave0.awvalid = 0;
    axi_slave0.wdata = 0;
    axi_slave0.wstrb = 0;
    axi_slave0.wvalid = 0;
    axi_slave0.araddr = 0;
    axi_slave0.arvalid = 0;
    axi_slave0.rready = 0;
  end else begin
    axi_slave0.awaddr = axi_master.awaddr;
    axi_slave0.awvalid = axi_master.awvalid;
    axi_slave0.wdata = axi_master.wdata;
    axi_slave0.wstrb = axi_master.wstrb;
    axi_slave0.wvalid = axi_master.wvalid;
    axi_slave0.araddr = axi_master.araddr;
    axi_slave0.arvalid = axi_master.arvalid;
    axi_slave0.rready = axi_master.rready;
    axi_master.awready = axi_slave1.awready;
    axi_master.wready = axi_slave1.wready;
    axi_master.rdata = axi_slave1.rdata;
    axi_master.rvalid = axi_slave1.rvalid;
    
    axi_slave1.awaddr = 0;
    axi_slave1.awvalid = 0;
    axi_slave1.wdata = 0;
    axi_slave1.wstrb = 0;
    axi_slave1.wvalid = 0;
    axi_slave1.araddr = 0;
    axi_slave1.arvalid = 0;
    axi_slave1.rready = 0;
  end
end

endmodule
