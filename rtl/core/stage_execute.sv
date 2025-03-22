module stage_execute (
  input logic clk,

  // RD passthrough
  input logic [4:0] decode_rd,
  output logic [4:0] execute_rd,

  // forwarding
  input logic [4:0] decode_rs1,
  input logic [4:0] decode_rs2,
  input logic [4:0] wb_rd,
  input logic [4:0] mem_rd,
  input logic [31:0] wb_write_data,
  input logic [31:0] mem_alu_result,
  input logic mem_regfile_wr_enable,
  input logic wb_regfile_wr_enable,
  input logic [1:0] mem_result_src,
  input logic [31:0] mem_read_data,

  // jump/branch src select passthrough to IF stage
  output logic execute_pc_src,

  // JAL/JALR src select passthrough to IF stage
  input logic decode_jump, // instr is a jump
  input logic decode_jal_src, // 1 = JAL, 0 = JALR
  output logic execute_jal_src,

  // PC target
  output logic [31:0] jal_instr_addr,
  output logic [31:0] jalr_instr_addr,
  input logic [31:0] decode_instr_addr,

  // PC + 4 passthrough
  input logic [31:0] decode_instr_addr_plus,
  output logic [31:0] execute_instr_addr_plus,

  // Branch control
  input logic decode_branch,

  // IMM or RS2
  input logic decode_alu_src,
  input logic [31:0] decode_imm,

  // RS1 RS2 data
  input logic [31:0] rs_data1,
  input logic [31:0] rs_data2,

  // ALU operation
  input logic [1:0] decode_alu_op, // alu op
  input logic [2:0] decode_funct3,
  input logic decode_funct7b5,
  output logic [2:0] execute_funct3,

  // LUI or AUIPC
  input logic decode_lui_auipc,

  // regfile write enable passthrough
  input logic decode_regfile_wr_enable,
  output reg execute_regfile_wr_enable,

  // data memory (passthrough)
  input logic decode_datamem_wr_enable,
  input logic [1:0] decode_result_src,
  output logic execute_datamem_wr_enable,
  output logic [1:0] execute_result_src,
  output logic [31:0] execute_wr_datamem_data,
  output logic [31:0] execute_alu_result
);

localparam [1:0]ALU_RESULT = 2'b00,
                MEM_TO_REG = 2'b01,
                   PC_PLUS = 2'b10,
                LUI_AUIPC  = 2'b11;

logic [31:0] data1, data2, datamem_data;
logic signed [31:0] signed_data1, signed_data2;
logic slt, sltu, sgte, zero, execute_branch;
logic [31:0] alu_result;
logic [31:0] add, sub, alu_or, alu_and, alu_xor, sll, srl, sra;
logic branch;

//assign zero = alu_result == 0;
// assign sign = alu_result[31];
assign execute_branch = branch && decode_branch;

always_comb begin
  case (decode_funct3)
    3'b000: branch = zero; // BEQ
    3'b001: branch = ~zero; // BNE
    3'b100: branch = slt; // BLT
    3'b101: branch = sgte; // BGE
    3'b110: branch = sltu; // BLTU
    3'b111: branch = ~sltu; // BGEU
    default: branch = 0;
  endcase

  if (decode_rs1 == execute_rd && execute_regfile_wr_enable)
    data1 = execute_alu_result;
  else if (decode_rs1 == mem_rd && mem_regfile_wr_enable)
    if (mem_result_src == MEM_TO_REG) begin
      data1 = rs_data1;
    end else begin // ALU_RESULT
      data1 = mem_alu_result;
    end
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

  case(decode_alu_op)
    2'b00: alu_result = add;
    2'b01: alu_result = sub;
    2'b10: begin
      case (decode_funct3)
        3'b000: begin
          if (decode_funct7b5 && ~decode_alu_src)
            alu_result = sub; // rs1 - rs2
          else
            alu_result = add; // rs1 + rs2
        end
        3'b001: alu_result = sll; // rs1 << rs2
        3'b010: alu_result = {31'b0, slt}; // signed(rs1) < signed(rs2)
        3'b011: alu_result = {31'b0, sltu}; // unsigned(rs1) < unsigned(rs2)
        3'b100: alu_result = alu_xor; // rs1 ^ rs2
        3'b101: begin
          if (decode_funct7b5)
            alu_result = sra; // rs1 >>> rs
          else
            alu_result = srl; // rs1 >> rs2
          end
        3'b110: alu_result = alu_or; // rs1 | rs2
        3'b111: alu_result = alu_and; // rs1 & rs2
        default: alu_result = 0;
      endcase
    end
    default: alu_result = add;
  endcase
end

assign signed_data1 = $signed(data1);
assign signed_data2 = $signed(data2);

/*
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
*/

// TODO: these values should not be clocked
always_ff @(posedge clk) begin
  jalr_instr_addr <= add;
  slt <= signed_data1 < signed_data2;
  sltu <= data1 < data2;
  sgte <= data1 >= data2;
  add <= signed_data1 + signed_data2;
  sub <= signed_data1 - signed_data2;
  alu_or <= data1 | data2;
  alu_and <= data1 & data2;
  alu_xor <= data1 ^ data2;
  sll <= data1 << data2[4:0];
  srl <= data1 >> data2[4:0];
  sra <= data1 >>> data2[4:0];
  zero <= alu_result == 0;
end

always_ff @(posedge clk) begin
  execute_funct3 <= decode_funct3;
  execute_datamem_wr_enable <= decode_datamem_wr_enable;
  execute_wr_datamem_data <= datamem_data;
  execute_instr_addr_plus <= decode_instr_addr_plus;
  execute_rd <= decode_rd;
  execute_regfile_wr_enable <= decode_regfile_wr_enable;
  execute_result_src <= decode_result_src;
  if (decode_result_src == LUI_AUIPC && ~decode_lui_auipc) // LUI
    execute_alu_result <= decode_imm;
  else if (decode_result_src == LUI_AUIPC && decode_lui_auipc) // AUIPC
    execute_alu_result <= decode_imm + decode_instr_addr;
  // else if (mem_rd == decode_rd && mem_result_src == MEM_TO_REG) // TODO wonky
  // execute_alu_result <= mem_rd_datamem_data;
  else
    execute_alu_result <= alu_result;
end

assign jal_instr_addr = (decode_imm << 1) + decode_instr_addr;
// assign jalr_instr_addr = add;
assign execute_jal_src = decode_jal_src;
assign execute_pc_src = decode_jump | execute_branch;

endmodule

