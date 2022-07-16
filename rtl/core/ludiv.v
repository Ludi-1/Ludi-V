`timescale 1ns/1ps
`include "../rtl/core/alu.v"
`include "../rtl/core/control.v"
`include "../rtl/core/data_mem.v"
`include "../rtl/core/imm_gen.v"
`include "../rtl/core/instr.v"
`include "../rtl/core/pc.v"
`include "../rtl/core/regfile.v"

module ludiv (
    input i_Clock,
    input i_Reset,

    output [3:0] o_ALUctl,
    output [63:0] o_PC, o_Immediate, o_ALUresult, o_ReadData, o_Rs1, o_Rs2,
    output [31:0] o_Instr,
    output o_Zero, o_Branch, o_MemToReg, o_ALUsrc, o_MemWrite, o_RegWrite
);

assign o_ALUctl = w_ALUctl,
    o_PC = w_PC,
    o_Immediate = w_Immediate,
    o_ALUresult = w_ALUresult,
    o_ReadData = w_ReadData,
    o_Rs1 = w_Rs1,
    o_Rs2 = w_Rs2,
    o_Instr = w_Instr,
    o_Zero = w_Zero,
    o_Branch = w_Branch,
    o_MemToReg = w_MemToReg,
    o_ALUsrc = w_ALUsrc,
    o_MemWrite = w_MemWrite,
    o_RegWrite = w_RegWrite;

wire [3:0] w_ALUctl;
wire [63:0] w_PC, w_Immediate, w_ALUresult, w_ReadData, w_Rs1, w_Rs2;
wire [31:0] w_Instr;
wire w_Zero, w_Branch, w_MemToReg, w_ALUsrc, w_MemWrite, w_RegWrite;

alu alu1 (
    .i_ALUctl(w_ALUctl),
    .i_Rs1(w_Rs1),
    .i_Rs2(w_Rs2),
    .i_Immediate(w_Immediate),
    .i_ALUsrc(w_ALUsrc),
    .o_Result(w_ALUresult),
    .o_Zero(w_Zero)
);

control control1 (
    .i_Instr(w_Instr),
    .o_ALUctl(w_ALUctl),
    .o_Branch(w_Branch),
    .o_ALUsrc(w_ALUsrc),
    .o_MemWrite(w_MemWrite),
    .o_RegWrite(w_RegWrite),
    .o_MemToReg(w_MemToReg)
);

data_mem data_mem1(
    .i_Clock(i_Clock),
    .i_Reset(i_Reset),
    .i_MemWrite(w_MemWrite),
    .i_Address(w_ALUresult),
    .o_ReadData(w_ReadData)
);

imm_gen imm_gen1(
    .i_Instr(w_Instr),
    .o_Immediate(w_Immediate)
);

instr instr1(
    .i_Clock(i_Clock),
    .i_Reset(i_Reset),
    .i_PC(w_PC),
    .o_Instr(w_Instr)
);

pc pc1(
    .i_Clock(i_Clock),
    .i_Reset(i_Reset),
    .i_Branch(w_Branch),
    .i_Zero(w_Zero),
    .i_Immediate(w_Immediate),
    .o_PC(w_PC)
);

regfile regfile1(
    .i_Clock(i_Clock),
    .i_Reset(i_Reset),
    .i_ReadReg1(w_Instr[19:15]),
    .i_ReadReg2(w_Instr[24:20]),
    .i_WriteReg(w_Instr[11:7]),
    .i_MemToReg(w_MemToReg),
    .i_RegWrite(w_RegWrite),
    .i_ReadData(w_ReadData),
    .i_ALUresult(w_ALUresult),
    .o_Data1(w_Rs1),
    .o_Data2(w_Rs2)
);

endmodule