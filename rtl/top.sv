module top (
    input logic clk,
    input logic rstn,

    output logic [3:0] led
//    input wire uart_rxd,
//     output wire uart_txd
);

localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;

axi_intf axi (clk, rstn);

core #(
  .ADDR_WIDTH(ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH)
) core_inst (
  .axi(axi.master)
);

led #(
  .ADDR_WIDTH(ADDR_WIDTH),
  .DATA_WIDTH(DATA_WIDTH)
) led_inst (
  .axi(axi.slave),
  .led(led)
);

//assign axi.slave.awready = 1;
//assign axi.slave.wready = 1;
//assign axi.slave.bvalid = 1;
//assign axi.slave.arready = 1;

//always_ff @(posedge clk) begin
//  if (axi.slave.wready && axi.slave.awready && axi.slave.wvalid && axi.slave.awvalid) begin
//    if (axi.slave.awaddr == 32'h00_00_00_FF) begin
//      led = axi.slave.wdata[3:0];
//    end
//  end
//end

// mig_7series_0 mig_ddr (
//     .sys_rst(rstn),
//     .aresetn(rstn)
// );
/*
localparam UART_DATA_WIDTH = 8;
wire uart_tx_busy, uart_rx_busy, uart_rx_overrun_error, uart_rx_frame_error;
wire [UART_DATA_WIDTH-1:0] uart_s_axis_tdata, uart_m_axis_tdata;
wire uart_s_axis_tvalid, uart_s_axis_tready, uart_m_axis_tvalid, uart_m_axis_tready;
*/
// axi_crossbar #(
//     .S_COUNT(1),
//     .M_COUNT(1),
//     .DATA_WIDTH(32),
//     .ADDR_WIDTH(32),
// ) axi_crossbar_inst (
//     .clk(clk),
//     .rst(~rstn),
// );

// uart #(
//     .DATA_WIDTH(UART_DATA_WIDTH)
// ) uart_axi (
//     .clk(clk),
//     .rst(~rstn),

//     .s_axis_tdata(uart_s_axis_tdata),
//     .s_axis_tvalid(uart_s_axis_tvalid),
//     .s_axis_tready(uart_s_axis_tready),

//     .m_axis_tdata(uart_m_axis_tdata),
//     .m_axis_tvalid(uart_m_axis_tvalid),
//     .m_axis_tready(uart_m_axis_tready),

//     .rxd(uart_rxd),
//     .txd(uart_txd),

//     .tx_busy(uart_tx_busy),
//     .rx_busy(uart_rx_busy),
//     .rx_overrun_error(uart_rx_overrun_error),
//     .rx_frame_error(uart_rx_frame_error),

//     .prescale(109) // Fclk / (baud*8) = 108.507
// );


endmodule
