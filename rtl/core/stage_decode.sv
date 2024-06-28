module stage_decode (
    input wire clk,
    input wire rst,

    // Pass instr add to EX stage
    input wire[31:0] fetch_instr_addr,
    input wire [31:0] fetch_instr_addr_plus,
    output reg [31:0] decode_instr_addr,
    output reg [31:0] decode_instr_addr_plus,

    // Instruction to be decoded
    input wire [31:0] instr,

    // Read data from register file
    output reg [31:0] rs_data1,
    output reg [31:0] rs_data2,

    // rd, funct3, imm
    output reg [4:0] decode_rd, // towards writeback
    output reg [3:0] decode_alu_ctrl, // alu ctrl
    output reg [4:0] decode_shamt, // shift amount
    output reg [31:0] decode_imm,

    output reg decode_jump,
    output reg decode_jal_src,
    output reg decode_branch,

    output reg decode_alu_src,

    // Writeback stage to registers
    output wire decode_wr_enable,
    output wire decode_mem_to_reg,
    input wire [4:0] wb_wr_addr,
    input wire [31:0] wb_wr_data,
    input wire wb_wr_enable
);

always_ff @(posedge clk) begin : instr_addr
    decode_instr_addr <= fetch_instr_addr;
    decode_instr_addr_plus <= fetch_instr_addr_plus;  
end

localparam [6:0]R_TYPE  = 7'b0110011,
                I_TYPE  = 7'b0010011,
                STORE   = 7'b0100011,
                LOAD    = 7'b0000011,
                BRANCH  = 7'b1100011,
                JALR    = 7'b1100111,
                JAL     = 7'b1101111,
                AUIPC   = 7'b0010111,
                LUI     = 7'b0110111;

wire [6:0] opcode;
wire [2:0] funct3;
wire [4:0] rd, rs1, rs2;
wire [6:0] funct7;
wire [11:0] i_imm;
wire [4:0] s_imm1;
wire [6:0] s_imm2;
wire [4:0] shamt;
wire [19:0] jal_imm;
wire alu_op;

assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign funct7 = instr[31:25];
assign i_imm = instr[31:20];
assign s_imm1 = instr[11:7];
assign s_imm2 = instr[31:25];
assign jal_imm = {instr[31], instr[19:12], instr[20], instr[30:21]};
assign shamt = instr[24:20]; // shift amount
assign alu_op = instr[30];

reg [31:0] regfile [31:0];
assign regfile[0] = 0;
reg [4:0] rs_addr1, rs_addr2, wr_addr;
reg [31:0] wr_data;
wire wr_enable;

assign rs_addr1 = rs1;
assign rs_addr2 = rs2;
assign wr_addr = wb_wr_addr;
assign wr_data = wb_wr_data;
assign wr_enable = wb_wr_enable;

always_ff @(posedge clk) begin: register_file
    if (rst) begin
        for(int i = 0; i < 32; i++) begin
            regfile[i] <= 0;
        end
    end else if (wr_enable) begin
        if (wr_addr > 0) begin
            regfile[wr_addr] <= wr_data;
        end
    end
    rs_data1 <= regfile[rs_addr1];
    rs_data2 <= regfile[rs_addr2];
end

always_ff @(posedge clk) begin
    decode_rd <= rd;
    decode_alu_ctrl <= {alu_op, funct3};
    decode_shamt <= shamt;
end

always_ff @(posedge clk) begin
    case (opcode)
        R_TYPE: begin
            decode_wr_enable <= 1;
            decode_mem_to_reg <= 0;
            decode_alu_src <= 0;
            decode_imm <= 0;
            decode_jump <= 0;
            decode_jal_src <= 0;
        end
        I_TYPE: begin
            decode_wr_enable <= 1;
            decode_mem_to_reg <= 0;
            decode_alu_src <= 1;
            decode_imm <= 32'(signed'(i_imm));
            decode_jump <= 0;
            decode_jal_src <= 0;
        end
        JAL: begin
            decode_wr_enable <= 1;
            decode_mem_to_reg <= 0;
            decode_alu_src <= 0; // dont care
            decode_imm <= {12'b0, jal_imm};
            decode_jump <= 1;
            decode_jal_src <= 1; // JAL = 1, JALR = 0
        end
        default: begin
            decode_wr_enable <= 0;
            decode_mem_to_reg <= 0;
            decode_alu_src <= 0;
            decode_imm <= 0;
            decode_jump <= 0;
            decode_jal_src <= 0;
        end
    endcase
end

// always_comb begin : rd_data
//     rd_data1 <= regfile[rd_addr1];
//     rd_data2 <= regfile[rd_addr2];
// end

endmodule