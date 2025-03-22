module core_wrapper #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
    input logic clk,
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
    output logic rready
);

axi_intf axi (clk, rstn);

core #(
  .ADDR_WIDTH(ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH)
) core_inst (
  .axi(axi.master)
);

assign awaddr = axi.slave.awaddr;
assign awvalid = axi.slave.awvalid;
assign axi.slave.awready = awready;
assign wdata = axi.slave.wdata;
assign wstrb = axi.slave.wstrb;
assign wvalid = axi.slave.wvalid;
assign axi.slave.wready = wready;
assign axi.slave.bvalid = bvalid;
assign araddr = axi.slave.araddr;
assign arvalid = axi.slave.arvalid;
assign axi.slave.arready = arready;
assign rready = axi.slave.rready;

endmodule
