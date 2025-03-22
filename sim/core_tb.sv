`timescale 1ns / 1ps

module core_tb;

  localparam ADDR_WIDTH = 32;
  localparam DATA_WIDTH = 32;

  
  logic clk;
  logic aresetn;
  axi_intf #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) axi (
    .aclk(clk),
    .aresetn(aresetn)
  );


  logic [ADDR_WIDTH-1:0] awaddr;
  logic awvalid;
  logic awready;
  logic [DATA_WIDTH-1:0] wdata;
  logic [(DATA_WIDTH/8)-1:0] wstrb;
  logic wvalid;
  logic wready;
  logic bvalid;
  logic bready;

  logic [ADDR_WIDTH-1:0] araddr;
  logic arvalid;
  logic arready;
  logic [DATA_WIDTH-1:0] rdata;
  logic rvalid;
  logic rready;

  core #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
//     .axi(axi.master)
    .clk(clk),
    .rstn(aresetn),

    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .wdata(wdata),
    .wstrb(wstrb),
    .wvalid(wvalid),
    .wready(wready),
    .bvalid(bvalid),
    .bready(bready),

    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),
    .rdata(rdata),
    .rvalid(rvalid),
    .rready(rready)
  );

  initial begin
    $dumpfile("runs/core_tb.vcd");
    $dumpvars(0, core_tb);
    $dumpvars(0, dut);
    // for (integer i = 0; i < 128; i = i + 1) $dumpvars(0, dut.mem.data_memory[i]);
    #100000;
    $finish;
  end

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz Clock
  end

  initial begin
    aresetn = 0;
    #15 aresetn = 1; // Release reset after 15 time units
  end

endmodule
