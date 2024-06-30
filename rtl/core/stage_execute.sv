module stage_execute (
    input wire clk,

    // RD passthrough
    input wire [4:0] decode_rd,
    output reg [4:0] execute_rd,

    // forwarding
    input wire [4:0] decode_rs1,
    input wire [4:0] decode_rs2,
    input wire [4:0] wb_rd,
    input wire [4:0] mem_rd,
    input wire [31:0] wb_write_data,
    input wire [31:0] mem_alu_result,
    input wire mem_regfile_wr_enable,
    input wire wb_regfile_wr_enable,

    // jump/branch src select passthrough to IF stage
    output reg execute_pc_src,

    // JAL/JALR src select passthrough to IF stage
    input wire decode_jump, // instr is a jump
    input wire decode_jal_src, // 1 = JAL, 0 = JALR
    output reg execute_jal_src,

    // PC target
    output reg [31:0] jal_instr_addr,
    output reg [31:0] jalr_instr_addr,
    input wire [31:0] decode_instr_addr,

    // PC + 4 passthrough
    input wire [31:0] decode_instr_addr_plus,
    output reg [31:0] execute_instr_addr_plus,

    // Branch control TODO
    input wire decode_branch, // TODO
    output reg execute_branch, // TODO

    // IMM or RS2
    input wire decode_alu_src,
    input wire [31:0] decode_imm,

    // RS1 RS2 data
    input wire [31:0] rs_data1,
    input wire [31:0] rs_data2,

    // shift amount (RS12)
    input wire [4:0] shamt,

    // ALU operation
    input wire [1:0] decode_alu_op, // alu op
    input wire [2:0] decode_funct3,
    input wire decode_funct7b5,

    output reg [2:0] execute_funct3,

    // regfile write enable passthrough
    input wire decode_regfile_wr_enable,
    output reg execute_regfile_wr_enable,

    // data memory (passthrough)
    input wire decode_datamem_wr_enable,
    input wire [1:0] decode_result_src,
    output reg execute_datamem_wr_enable,
    output reg [1:0] execute_result_src,
    output reg [31:0] execute_wr_datamem_data,
    output reg [31:0] execute_alu_result
);

reg [31:0] data1, data2, datamem_data;
wire signed [31:0] signed_data1, signed_data2;
wire slt, sltu, sgte;
wire [31:0] alu_result;
wire [31:0] add, sub, alu_or, alu_and, alu_xor, sll, srl, sra;

always_comb begin
    if (decode_rs1 == execute_rd && execute_regfile_wr_enable)
        data1 = execute_alu_result;
    else if (decode_rs1 == mem_rd && mem_regfile_wr_enable)
        data1 = mem_alu_result;
    else if (decode_rs1 == wb_rd && wb_regfile_wr_enable)
        data1 = wb_write_data;
    else
        data1 = rs_data1;

    if (decode_rs2 == execute_rd && execute_regfile_wr_enable)
        datamem_data = execute_alu_result;
    else if (decode_rs2 == mem_rd && mem_regfile_wr_enable)
        datamem_data = mem_alu_result;
    else if (decode_rs2 == wb_rd && wb_regfile_wr_enable)
        datamem_data = wb_write_data;
    else
        datamem_data = rs_data2;

    if (decode_alu_src)
        data2 = decode_imm;
    else begin
        data2 = datamem_data;
    end
end

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
    case(decode_alu_op)
        2'b00: execute_alu_result <= add;
        2'b01: execute_alu_result <= sub;
        2'b10: begin
        case (decode_funct3)
            3'b000: begin
                if (decode_funct7b5 && ~decode_alu_src)
                    execute_alu_result <= sub; // rs1 - rs2
                else
                    execute_alu_result <= add; // rs1 + rs2
            end
            3'b001: execute_alu_result <= sll; // rs1 << rs2
            3'b010: execute_alu_result <= {31'b0, slt}; // signed(rs1) < signed(rs2)
            3'b011: execute_alu_result <= {31'b0, sltu}; // unsigned(rs1) < unsigned(rs2)
            3'b100: execute_alu_result <= alu_xor; // rs1 ^ rs2
            3'b101: begin
                if (decode_funct7b5)
                    execute_alu_result <= sra; // rs1 >>> rs
                else
                    execute_alu_result <= srl; // rs1 >> rs2
            end
            3'b110: execute_alu_result <= alu_or; // rs1 | rs2
            3'b111: execute_alu_result <= alu_and; // rs1 & rs2
            default: execute_alu_result <= 0;
        endcase
        end
        default: execute_alu_result <= add;
    endcase

    execute_funct3 <= decode_funct3;
    execute_datamem_wr_enable <= decode_datamem_wr_enable;
    execute_wr_datamem_data = datamem_data;
    execute_instr_addr_plus <= decode_instr_addr_plus;
    execute_rd <= decode_rd;
    execute_regfile_wr_enable <= decode_regfile_wr_enable;
    // jal_instr_addr <= (decode_imm << 1) + decode_instr_addr;
    // execute_jal_src <= decode_jal_src;
    // execute_pc_src <= decode_jump; // TODO: add branch
    execute_result_src <= decode_result_src;
end

assign jal_instr_addr = (decode_imm << 1) + decode_instr_addr;
assign jalr_instr_addr = add;
assign execute_jal_src = decode_jal_src;
assign execute_pc_src = decode_jump; // TODO: add branch

endmodule