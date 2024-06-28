module stage_fetch (
    input wire clk,
    input wire rst,
    input wire pc_src,
    input wire jal_src,
    input wire flush_fetch,
    output reg [31:0] fetch_instr_addr_plus,
    input wire [31:0] branch_instr_addr,
    input wire [31:0] jalr_instr_addr,
    input wire [31:0] jal_instr_addr,
    output reg [31:0] fetch_instr_addr,
    output reg [31:0] fetch_instr
);

reg [31:0] jump_addr, instr, instr_addr, next_instr_addr;
assign jump_addr = jal_src ? jal_instr_addr : jalr_instr_addr;
assign next_instr_addr = pc_src ? jump_addr : instr_addr + 4;

instr_mem instr_mem1 (
    .address(instr_addr),
    .instr(instr)
);

always_ff @(posedge clk) begin : pc
    fetch_instr_addr <= instr_addr;
    fetch_instr_addr_plus <= instr_addr + 4;
    fetch_instr <= flush_fetch ? 0 : instr;
    if (rst) begin
        instr_addr <= 0;
    end else begin
        instr_addr <= next_instr_addr;
    end
end

endmodule