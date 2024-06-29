module stage_execute (
    input wire clk,

    input wire [4:0] decode_rd,
    output reg [4:0] execute_rd,

    input reg decode_jump,
    input reg decode_jal_src,
    input reg decode_branch, // TODO
    output reg execute_jal_src,
    output reg execute_pc_src,
    output reg execute_branch, // TODO

    output reg [31:0] jal_instr_addr,
    output reg [31:0] jalr_instr_addr,

    input wire [31:0] decode_instr_addr,
    output reg [31:0] execute_next_instr_addr,

    input wire [31:0] decode_instr_addr_plus,
    output reg [31:0] execute_instr_addr_plus,

    input wire decode_alu_src,
    input wire [31:0] decode_imm,

    input wire [31:0] rs_data1,
    input wire [31:0] rs_data2,
    input wire [4:0] shamt,

    input wire [3:0] alu_ctrl,

    output reg [31:0] execute_alu_result,
    input wire decode_wr_enable,
    input wire [1:0] decode_result_src,
    output wire execute_wr_enable,
    output wire [1:0] execute_result_src
);

wire [31:0] data1, data2;
wire signed [31:0] signed_data1, signed_data2;
wire slt, sltu, sgte;
wire [31:0] alu_result;
wire [31:0] add, sub, alu_or, alu_and, alu_xor, sll, srl, sra;
assign data1 = rs_data1;
assign data2 = decode_alu_src ? decode_imm : rs_data2;
assign signed_data1 = $signed(data1);
assign signed_data2 = $signed(data2);

assign slt = signed_data1 < signed_data2;
assign sltu = data1 < data2;
assign sgte = data1 >= data2;

assign add = signed_data1 + signed_data2;
assign sub = signed_data1 - signed_data2;
assign alu_or = data1 | data2;
assign alu_and = data1 & data2;
assign alu_xor = data1 ^ data2;

assign sll = data1 << data2[4:0];
assign srl = data1 >> data2[4:0];
assign sra = data1 >>> data2[4:0];

always_ff @(posedge clk) begin
    case (alu_ctrl[2:0])
        3'b000: begin
            if (alu_ctrl[3] && ~decode_alu_src)
                execute_alu_result <= sub; // rs1 - rs2
            else
                execute_alu_result <= add; // rs1 + rs2
        end
        3'b001: execute_alu_result <= sll; // rs1 << rs2
        // 4'b0010: execute_alu_result <= slt; // signed(rs1) < signed(rs2)
        // 4'b0011: execute_alu_result <= sltu; // unsigned(rs1) < unsigned(rs2)
        3'b100: execute_alu_result <= alu_xor; // rs1 ^ rs2
        3'b101: begin
            if (alu_ctrl[3])
                execute_alu_result <= sra; // rs1 >>> rs
            else
                execute_alu_result <= srl; // rs1 >> rs2
        end
        3'b110: execute_alu_result <= alu_or; // rs1 | rs2
        3'b111: execute_alu_result <= alu_and; // rs1 & rs2
        default: execute_alu_result <= 0;
    endcase

    execute_instr_addr_plus <= decode_instr_addr_plus;
    execute_rd <= decode_rd;
    execute_wr_enable <= decode_wr_enable;
    jal_instr_addr <= (decode_imm << 1) + decode_instr_addr;
    execute_jal_src <= decode_jal_src;
    execute_pc_src <= decode_jump; // TODO: add branch
    execute_result_src <= decode_result_src;
end

assign jalr_instr_addr = execute_alu_result;


endmodule