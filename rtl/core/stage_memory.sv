module stage_memory (
    input wire clk,
    input wire [4:0] execute_rd,
    output reg [4:0] mem_rd,
    input wire [31:0] execute_alu_result,
    output reg [31:0] mem_alu_result,
    input wire [31:0] execute_instr_addr_plus,
    output reg [31:0] mem_instr_addr_plus,
    input wire [1:0] execute_result_src,
    input wire execute_wr_enable,
    output reg mem_wr_enable,
    output reg [1:0] mem_result_src
);

always_ff @(posedge clk) begin
    mem_alu_result <= execute_alu_result;
    mem_rd <= execute_rd;
    mem_wr_enable <= execute_wr_enable;
    mem_instr_addr_plus <= execute_instr_addr_plus;
    mem_result_src <= execute_result_src;
end

endmodule