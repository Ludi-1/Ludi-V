module stage_memory (
    input wire clk,
    input wire [4:0] execute_rd,
    output reg [4:0] mem_rd,
    input wire [31:0] execute_alu_result,
    output reg [31:0] mem_alu_result,
    input wire execute_mem_to_reg,
    input wire execute_wr_enable,
    output reg mem_wr_enable,
    output reg mem_mem_to_reg
);

always_ff @(posedge clk) begin
    mem_alu_result <= execute_alu_result;
    mem_rd <= execute_rd;
end

endmodule