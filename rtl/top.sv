module top (
    input wire clk,
    input wire rstn,

    input wire uart_rxd,
    output wire uart_txd
);

`ifdef COCOTB_SIM
initial
begin
   $dumpfile("dump.vcd");
   $dumpvars(0,top);
end

`else

// mig_7series_0 mig_ddr (
//     .sys_rst(rstn),
//     .aresetn(rstn)
// );

`endif

localparam UART_DATA_WIDTH = 8;
wire uart_tx_busy, uart_rx_busy, uart_rx_overrun_error, uart_rx_frame_error;
wire [UART_DATA_WIDTH-1:0] uart_s_axis_tdata, uart_m_axis_tdata;
wire uart_s_axis_tvalid, uart_s_axis_tready, uart_m_axis_tvalid, uart_m_axis_tready;

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

wire execute_pc_src, execute_jal_src, flush_fetch;
wire [31:0] fetch_instr_addr_plus,
            jal_instr_addr,
            jalr_instr_addr,
            fetch_instr_addr,
            fetch_instr;
assign flush_fetch = execute_pc_src;
stage_fetch fetch (
    .clk(clk),
    .rstn(rstn),
    .pc_src(execute_pc_src),
    .jal_src(execute_jal_src),
    .jalr_instr_addr(jalr_instr_addr),
    .jal_instr_addr(jal_instr_addr),
    .flush_fetch(flush_fetch),
    .fetch_instr_addr_plus(fetch_instr_addr_plus),
    .fetch_instr_addr(fetch_instr_addr),
    .fetch_instr(fetch_instr)
);

wire [31:0] decode_rs_data1, decode_rs_data2, decode_imm;
wire [4:0] decode_rd, wb_rd, decode_rs1, decode_rs2;
wire [1:0] decode_alu_op;
wire [2:0] decode_funct3, execute_funct3;
wire decode_funct7b5;
wire [31:0] decode_instr_addr, decode_instr_addr_plus;

wire decode_jump, decode_jal_src, decode_branch, decode_regfile_wr_enable, decode_alu_src, wb_regfile_wr_enable, flush_decode;
wire [31:0] wb_write_data;
assign flush_decode = decode_jump;

wire decode_datamem_wr_enable, execute_datamem_wr_enable;
wire [1:0] decode_result_src, execute_result_src;

wire [4:0] mem_rd;
wire [31:0] mem_rd_datamem_data, mem_alu_result, mem_instr_addr_plus;
wire mem_regfile_wr_enable;
wire [1:0] mem_result_src;

wire [31:0] execute_instr_addr_plus, execute_alu_result;
wire [4:0] execute_rd;
wire execute_regfile_wr_enable;
wire [31:0] execute_wr_datamem_data;

stage_decode decode (
    .clk(clk),
    .rstn(rstn),
    .flush(flush_decode),

    .instr(fetch_instr),
    .fetch_instr_addr(fetch_instr_addr),
    .fetch_instr_addr_plus(fetch_instr_addr_plus),

    .decode_instr_addr(decode_instr_addr),
    .decode_instr_addr_plus(decode_instr_addr_plus),

    .rs_data1(decode_rs_data1),
    .rs_data2(decode_rs_data2),

    .decode_datamem_wr_enable(decode_datamem_wr_enable),

    .decode_rd(decode_rd),
    .decode_rs1(decode_rs1),
    .decode_rs2(decode_rs2),

    .decode_alu_op(decode_alu_op),
    .decode_funct3(decode_funct3),
    .decode_funct7b5(decode_funct7b5),
    .decode_imm(decode_imm),

    .decode_jump(decode_jump),
    .decode_jal_src(decode_jal_src),
    .decode_branch(decode_branch),

    .decode_alu_src(decode_alu_src),
    .decode_lui_auipc(decode_lui_auipc),

    .decode_regfile_wr_enable(decode_regfile_wr_enable),
    .decode_result_src(decode_result_src),
    .wb_wr_addr(wb_rd),
    .wb_wr_data(wb_write_data),
    .wb_regfile_wr_enable(wb_regfile_wr_enable)
);

stage_execute execute (
    .clk(clk),

    .decode_rd(decode_rd),
    .execute_rd(execute_rd),

    .decode_rs1(decode_rs1),
    .decode_rs2(decode_rs2),
    .wb_rd(wb_rd),
    .mem_rd(mem_rd),
    .wb_write_data(wb_write_data),
    .mem_alu_result(mem_alu_result),
    .mem_regfile_wr_enable(mem_regfile_wr_enable),
    .wb_regfile_wr_enable(wb_regfile_wr_enable),

    .execute_pc_src(execute_pc_src),

    .decode_jump(decode_jump),
    .decode_jal_src(decode_jal_src),
    .execute_jal_src(execute_jal_src),

    .jal_instr_addr(jal_instr_addr),
    .jalr_instr_addr(jalr_instr_addr),
    .decode_instr_addr(decode_instr_addr),

    .decode_instr_addr_plus(decode_instr_addr_plus),
    .execute_instr_addr_plus(execute_instr_addr_plus),

    .decode_branch(decode_branch),

    .decode_alu_src(decode_alu_src),
    .decode_imm(decode_imm),

    .rs_data1(decode_rs_data1),
    .rs_data2(decode_rs_data2),

    .decode_alu_op(decode_alu_op),
    .decode_funct3(decode_funct3),
    .decode_funct7b5(decode_funct7b5),

    .execute_funct3(execute_funct3),
    .decode_lui_auipc(decode_lui_auipc),

    .decode_regfile_wr_enable(decode_regfile_wr_enable),
    .execute_regfile_wr_enable(execute_regfile_wr_enable),

    .decode_datamem_wr_enable(decode_datamem_wr_enable),
    .decode_result_src(decode_result_src),
    .execute_datamem_wr_enable(execute_datamem_wr_enable),
    .execute_result_src(execute_result_src),

    .execute_wr_datamem_data(execute_wr_datamem_data),
    .execute_alu_result(execute_alu_result)
);

stage_memory mem (
    .clk(clk),

    .execute_rd(execute_rd),
    .mem_rd(mem_rd),

    .execute_regfile_wr_enable(execute_regfile_wr_enable),
    .mem_regfile_wr_enable(mem_regfile_wr_enable),

    .execute_alu_result(execute_alu_result),
    .mem_alu_result(mem_alu_result),

    .execute_instr_addr_plus(execute_instr_addr_plus),
    .mem_instr_addr_plus(mem_instr_addr_plus),

    .execute_result_src(execute_result_src),
    .mem_result_src(mem_result_src),

    .execute_datamem_wr_enable(execute_datamem_wr_enable),
    .execute_funct3(execute_funct3),
    .execute_wr_datamem_data(execute_wr_datamem_data),
    .mem_rd_datamem_data(mem_rd_datamem_data)
);

stage_writeback wb (
    .clk(clk),
    .mem_rd(mem_rd),
    .wb_rd(wb_rd),
    .mem_instr_addr_plus(mem_instr_addr_plus),
    .mem_result_src(mem_result_src),
    .mem_alu_result(mem_alu_result),
    .mem_read_data(mem_rd_datamem_data),
    .wb_write_data(wb_write_data),
    .mem_regfile_wr_enable(mem_regfile_wr_enable),
    .wb_regfile_wr_enable(wb_regfile_wr_enable)
);

endmodule