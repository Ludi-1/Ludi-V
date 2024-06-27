module stage_execute (
    input wire clk,

    input wire [4:0] decode_rd,
    output reg [4:0] execute_rd,

    input wire [31:0] decode_instr_addr,
    output wire [31:0] execute_next_instr_addr,

    input wire [31:0] rs_data1,
    input wire [31:0] rs_data2,
    input wire [4:0] shamt,

    input wire [3:0] alu_ctrl,

    output reg [31:0] execute_alu_result,
    input wire decode_wr_enable,
    input wire decode_mem_to_reg,
    output wire execute_wr_enable,
    output wire execute_mem_to_reg
);

wire signed [31:0] signed_rs_data1, signed_rs_data2;
wire slt, sltu, sgte;
wire [31:0] alu_result;
wire [31:0] add, sub, alu_or, alu_and, alu_xor, sll, srl, sra;
assign signed_rs_data1 = $signed(rs_data1);
assign signed_rs_data2 = $signed(rs_data2);

assign slt = signed_rs_data1 < signed_rs_data2;
assign sltu = rs_data1 < rs_data2;
assign sgte = rs_data1 >= rs_data2;

assign add = rs_data1 + rs_data2;
assign sub = rs_data1 - rs_data2;
assign alu_or = rs_data1 | rs_data2;
assign alu_and = rs_data1 & rs_data2;
assign alu_xor = rs_data1 ^ rs_data2;

assign sll = rs_data1 << rs_data2[4:0];
assign srl = rs_data1 >> rs_data2[4:0];
assign sra = rs_data1 >>> rs_data2[4:0];

always_ff @(posedge clk) begin
    case (alu_ctrl)
        4'b0000: execute_alu_result <= add; // rs1 + rs2
        4'b0001: execute_alu_result <= sll; // rs1 << rs2
        // 4'b0010: execute_alu_result <= slt; // signed(rs1) < signed(rs2)
        // 4'b0011: execute_alu_result <= sltu; // unsigned(rs1) < unsigned(rs2)
        4'b0100: execute_alu_result <= alu_xor; // rs1 ^ rs2
        4'b0101: execute_alu_result <= srl; // rs1 >> rs2
        4'b0110: execute_alu_result <= alu_or; // rs1 | rs2
        4'b0111: execute_alu_result <= alu_and; // rs1 & rs2
        4'b1000: execute_alu_result <= sub; // rs1 - rs2
        4'b1101: execute_alu_result <= sra; // rs1 >>> rs2
        default: execute_alu_result <= 0;
    endcase

    execute_rd <= decode_rd;
end

endmodule