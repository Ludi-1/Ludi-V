`timescale 1ns/10ps
 
`include "../rtl/core/regfile.v"
 
module regfile_tb ();
    parameter c_CLOCK_PERIOD_NS = 100;
    reg r_Clock = 0, r_Reset = 1;
    reg [4:0] r_ReadReg1 = 0, r_ReadReg2 = 0, r_WriteReg = 0;
    reg [63:0] r_ReadData = 0, r_ALUresult = 0;
    reg r_MemToReg = 0, r_RegWrite = 0;
    wire [63:0] w_Data1, w_Data2;

regfile dut(
    .i_Clock(r_Clock), .i_Reset(r_Reset),

    .i_ReadReg1(r_ReadReg1),
    .i_ReadReg2(r_ReadReg2),
    .i_WriteReg(r_WriteReg),

    .i_MemToReg(r_MemToReg),
    .i_RegWrite(r_RegWrite),

    .i_ALUresult(r_ALUresult),
    .i_ReadData(r_ReadData),

    .o_Data1(w_Data1),
    .o_Data2(w_Data2)
);
 
always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
   
// Main Testing:
initial begin
    $dumpfile("../runs/regfile_tb.vcd");
    $dumpvars(0,r_Clock, r_Reset, r_ReadReg1, r_ReadReg2, r_WriteReg, r_ReadData, r_ALUresult, r_MemToReg, r_RegWrite, w_Data1, w_Data2);
    $display("Begin simulation");
    @(posedge r_Clock);
    r_Reset <= 0;
    //Read registers 0 and 1
    r_ReadReg1 <= 0; r_ReadReg2 <= 1;
    @(posedge r_Clock);
    //Write to register 0
    r_RegWrite<= 1; r_WriteReg <= 0; r_ALUresult <= 64'hFFFF;
    @(posedge r_Clock);
    //Write to register 1
    r_WriteReg <= 1; r_ALUresult  <= 64'hFFFF;
    @(posedge r_Clock);
    //Write to register 2
    r_WriteReg <= 2; r_ALUresult  <= 64'hFFFF;
    //Read from register 2
    r_ReadReg1 <= 2;
    @(posedge r_Clock);
    r_WriteReg <= 1; r_ALUresult  <= 64'hAFFFF;
    @(posedge r_Clock);
    r_RegWrite<= 0;
end

initial begin
    #200000;
    $finish;
end

endmodule