`timescale 1ns/10ps
 
`include "../rtl/core/data_mem.v"
 
module regfile_tb ();
    parameter c_CLOCK_PERIOD_NS = 100;
    reg r_MemWrite;
    reg [63:0] r_Address, r_Data;
    wire [63:0] w_ReadData;

data_mem dut (
    .i_Clock(r_Clock), .i_Reset(r_Reset),

    .i_MemWrite(r_MemWrite),
    .i_Address(r_Address),
    .i_Data(r_Data),

    .o_Data1(w_ReadData)
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