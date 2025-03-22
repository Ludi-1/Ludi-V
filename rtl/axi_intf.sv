interface axi_intf #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (
  input logic aclk,
  input logic aresetn
);
  
  // Write Address Channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [7:0]            awlen;
  logic                  awvalid;
  logic                  awready;

  // Write Data Channel
  logic [DATA_WIDTH-1:0] wdata;
  logic [(DATA_WIDTH/8)-1:0] wstrb;
  logic                  wlast;
  logic                  wvalid;
  logic                  wready;

  // Write Response Channel
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  // Read Address Channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic [7:0]            arlen;
  logic                  arvalid;
  logic                  arready;

  // Read Data Channel
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic                  rvalid;
  logic                  rready;

  // Modport for Master
  modport master (
    input aclk, aresetn,
    output awaddr, awlen, awvalid,
    input awready,
    output wdata, wstrb, wlast, wvalid,
    input wready,
    input bresp, bvalid,
    output bready,
    output araddr, arlen, arvalid,
    input arready,
    input rdata, rresp, rvalid,
    output rready
  );

  // Modport for Slave
  modport slave (
    input aclk, aresetn,
    input awaddr, awlen, awvalid,
    output awready,
    input wdata, wstrb, wlast, wvalid,
    output wready,
    output bresp, bvalid,
    input bready,
    input araddr, arlen, arvalid,
    output arready,
    output rdata, rresp, rvalid,
    input rready
  );
endinterface
