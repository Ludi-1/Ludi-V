module stage_fetch (
    input wire clk,
    input wire rst,
    input wire branch,

    input reg [31:0] branch_instr_addr,
    output reg [31:0] instr_addr,
    output reg [31:0] instr
);

always_ff @(posedge clk) begin : pc
    if (rst) begin
        instr_addr <= 0;
    end else begin
        instr_addr <= branch ? branch_instr_addr : instr_addr + 4;
    end
end

instr_mem instr_mem1 (
    .address(instr_addr),
    .instr(instr)
);

endmodule