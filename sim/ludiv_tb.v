`timescale 1ns/10ps
 
`include "../rtl/core/ludiv.v"
 
module ludiv_tb ();
parameter c_CLOCK_PERIOD_NS = 100;
reg r_Clock = 0;
reg r_Reset = 1;

wire [3:0] w_ALUctl;
wire [63:0] w_PC, w_Immediate, w_ALUresult, w_ReadData, w_Rs1, w_Rs2;
wire [31:0] w_Instr;
wire w_Zero, w_Branch, w_MemToReg, w_ALUsrc, w_MemWrite, w_RegWrite;

output [3:0] o_ALUctl;
output [63:0] o_PC, o_Immediate, o_ALUresult, o_ReadData, o_Rs1, o_Rs2;
output [31:0] o_Instr;
output o_Zero, o_Branch, o_MemToReg, o_ALUsrc, o_MemWrite, o_RegWrite;

ludiv dut(
    .i_Clock(r_Clock),
    .i_Reset(r_Reset),
    .o_ALUctl(w_ALUctl),
    .o_PC(w_PC),
    .o_Immediate(w_Immediate),
    .o_ALUresult(w_ALUresult),
    .o_ReadData(w_ReadData),
    .o_Rs1(w_Rs1),
    .o_Rs2(w_Rs2),
    .o_Instr(w_Instr),
    .o_Zero(w_Zero),
    .o_Branch(w_Branch), 
    .o_MemToReg(w_MemToReg),
    .o_ALUsrc(w_ALUsrc),
    .o_MemWrite(w_MemWrite),
    .o_RegWrite(w_RegWrite)
);
 
always #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
   
// Main Testing:
initial begin
    $dumpfile("../runs/ludiv_tb.vcd");
    $dumpvars(0,r_Clock,r_Reset,w_ALUctl,w_PC, w_Immediate, w_ALUresult, w_ReadData, w_Rs1, w_Rs2, w_Instr, w_Zero, w_Branch, w_MemToReg, w_ALUsrc, w_MemWrite, w_RegWrite);
    $display("Begin simulation");
    @(posedge r_Clock);
    r_Reset <= 0;
end

initial begin
    #200000;
    $finish;
end

endmodule