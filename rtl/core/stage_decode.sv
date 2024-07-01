module stage_decode (
    input wire clk,
    input wire rst,
    input wire flush,

    // Instruction to be decoded
    input wire [31:0] instr,
    input wire[31:0] fetch_instr_addr,
    input wire [31:0] fetch_instr_addr_plus,

    output reg [31:0] decode_instr_addr,
    output reg [31:0] decode_instr_addr_plus,

    // Read data from register file
    output reg [31:0] rs_data1,
    output reg [31:0] rs_data2,

    output reg decode_datamem_wr_enable,

    output reg [4:0] decode_rd, // rd towards writeback
    output reg [4:0] decode_rs1,
    output reg [4:0] decode_rs2,

    // decode ctrl
    output reg [1:0] decode_alu_op, // alu op
    output reg [2:0] decode_funct3,
    output reg decode_funct7b5,
    output reg [31:0] decode_imm, // select imm value for ALU

    output reg decode_jump,
    output reg decode_jal_src,
    output reg decode_branch,

    output reg decode_alu_src, // alu imm or rs data
    output reg decode_lui_auipc, // lui or auipc

    // Writeback stage to registers
    output reg decode_regfile_wr_enable,
    output reg [1:0] decode_result_src,
    input wire [4:0] wb_wr_addr,
    input wire [31:0] wb_wr_data,
    input wire wb_regfile_wr_enable
);

localparam [1:0]ALU_RESULT = 2'b00,
                MEM_TO_REG = 2'b01,
                   PC_PLUS = 2'b10,
                LUI_AUIPC  = 2'b11;

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
wire funct7b5;
wire [11:0] i_imm;
wire [11:0] s_imm;
wire [11:0] b_imm;
wire [19:0] lui_auipc_imm;
wire [19:0] jal_imm;

assign opcode = instr[6:0];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd = instr[11:7];
assign funct7b5 = instr[30];
assign i_imm = instr[31:20];
assign jal_imm = {instr[31], instr[19:12], instr[20], instr[30:21]};
assign s_imm = {instr[31:25], instr[11:7]};
assign b_imm = {instr[31], instr[7], instr[30:25], instr[11:8]};
assign lui_auipc_imm = instr[31:12];

reg [31:0] regfile [31:0];
reg [4:0] rs_addr1, rs_addr2, wr_addr;
reg [31:0] wr_data;
wire wr_enable;

assign rs_addr1 = rs1;
assign rs_addr2 = rs2;
assign wr_addr = wb_wr_addr;
assign wr_data = wb_wr_data;
assign wr_enable = wb_regfile_wr_enable;

always_ff @(posedge clk) begin: register_file
    regfile[0] <= 0;
    if (rst) begin
        for(int i = 0; i < 32; i++) begin
            regfile[i] <= 0;
        end
    end else if (wr_enable) begin
        if (wr_addr > 0) begin
            regfile[wr_addr] <= wr_data;
        end
    end
end

always_ff @(posedge clk) begin
    if (flush) begin
        decode_regfile_wr_enable <= 0;
        decode_result_src <= 0;
        decode_alu_src <= 0;
        decode_imm <= 0;
        decode_jump <= 0;
        decode_branch <= 0;
        decode_jal_src <= 0;
        rs_data1 <= 0;
        rs_data2 <= 0;
        decode_rd <= 0;
        decode_alu_op <= 0;
        decode_funct3 <= 0;
        decode_funct7b5 <= 0;
        decode_instr_addr <= 0;
        decode_instr_addr_plus <= 0;
        decode_rs1 <= 0;
        decode_rs2 <= 0;
        decode_lui_auipc <= 0;
        decode_datamem_wr_enable <= 0;
    end else begin
        decode_instr_addr <= fetch_instr_addr;
        decode_instr_addr_plus <= fetch_instr_addr_plus;  
        rs_data1 <= regfile[rs_addr1];
        rs_data2 <= regfile[rs_addr2];
        decode_rd <= rd;
        decode_funct3 <= funct3;
        decode_funct7b5 <= funct7b5;
        decode_rs1 <= rs1;
        decode_rs2 <= rs2;
        case (opcode)
            R_TYPE: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= ALU_RESULT;
                decode_alu_src <= 0;
                decode_imm <= 0;
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0;
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b10;
                decode_lui_auipc <= 0;
            end
            I_TYPE: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= ALU_RESULT;
                decode_alu_src <= 1;
                decode_imm <= {{20{i_imm[11]}}, i_imm};
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0;
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b10;
                decode_lui_auipc <= 0;
            end
            JAL: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= PC_PLUS;
                decode_alu_src <= 0; // dont care
                decode_imm <= {{20{jal_imm[19]}}, jal_imm};
                decode_jump <= 1;
                decode_branch <= 0;
                decode_jal_src <= 1; // JAL = 1, JALR = 0
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b00;
                decode_lui_auipc <= 0;
            end
            JALR: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= PC_PLUS;
                decode_alu_src <= 0;
                decode_imm <= 0;
                decode_jump <= 1;
                decode_branch <= 0;
                decode_jal_src <= 0; // JAL = 1, JALR = 0
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b00;
                decode_lui_auipc <= 0;
            end
            STORE: begin
                decode_regfile_wr_enable <= 0;
                decode_result_src <= ALU_RESULT; // dont care
                decode_alu_src <= 1;
                decode_imm <= {{20{s_imm[11]}}, s_imm};
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0; // dont care
                decode_datamem_wr_enable <= 1;
                decode_alu_op <= 2'b00;
                decode_lui_auipc <= 0;
            end
            LOAD: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= MEM_TO_REG;
                decode_alu_src <= 1;
                decode_imm <= {{20{i_imm[11]}}, i_imm};
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0; // dont care
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b00;
                decode_lui_auipc <= 0;
            end
            BRANCH: begin
                decode_regfile_wr_enable <= 0;
                decode_result_src <= ALU_RESULT; // dont care
                decode_alu_src <= 0;
                decode_imm <= {{20{b_imm[11]}}, b_imm};
                decode_jump <= 0;
                decode_branch <= 1;
                decode_jal_src <= 1;
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b01;
                decode_lui_auipc <= 0;
            end
            LUI: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= LUI_AUIPC;
                decode_alu_src <= 0; // dont care
                decode_imm <= {lui_auipc_imm, 12'b0};
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0;
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b00; // dont care
                decode_lui_auipc <= 0; // 0 = LUI, 1 = AUIPC
            end
            AUIPC: begin
                decode_regfile_wr_enable <= 1;
                decode_result_src <= LUI_AUIPC;
                decode_alu_src <= 0; // dont care
                decode_imm <= {lui_auipc_imm, 12'b0};
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0;
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b00; // dont care
                decode_lui_auipc <= 1;
            end
            default: begin
                decode_regfile_wr_enable <= 0;
                decode_result_src <= ALU_RESULT;
                decode_alu_src <= 0;
                decode_imm <= 0;
                decode_jump <= 0;
                decode_branch <= 0;
                decode_jal_src <= 0;
                decode_datamem_wr_enable <= 0;
                decode_alu_op <= 2'b00;
                decode_lui_auipc <= 0;
            end
        endcase
    end
end

`ifdef COCOTB_SIM
initial begin
    for (integer i = 0; i < 32; i = i + 1) $dumpvars(0, regfile[i]);
end
`endif

endmodule