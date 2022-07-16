`timescale 1ns/10ps
 
`include "../rtl/core/alu.v"
 
module alu_tb ();
reg r_ALUsrc = 0;
reg [3:0] r_ALUctl = 0;
reg [63:0] r_Rs1 = 0, r_Rs2 = 0, r_Immediate = 0;
wire [63:0] w_Result;
wire w_Zero;
    
alu dut(
    .i_ALUctl(r_ALUctl),
    .i_Rs1(r_Rs1),
    .i_Rs2(r_Rs2),
    .i_Immediate(r_Immediate),
    .i_ALUsrc(r_ALUsrc),
    .o_Result(w_Result),
    .o_Zero(w_Zero)
);
   
// Main Testing:
initial begin
    $dumpfile("../runs/alu_tb.vcd");
    $dumpvars(0,r_ALUctl, r_Rs1, r_Rs2, r_Immediate, r_ALUsrc, w_Result, w_Zero);
    $display("Begin simulation");
    #200; r_ALUctl <= 2; r_Rs1 <= 0; r_Immediate <= 7; r_ALUsrc <= 1;
    #200; r_ALUctl <= 2; r_Rs1 <= 5; r_Rs2 <= 7; r_ALUsrc <= 0;

//     #200; r_ALUctl <= 4'b0000;  r_Rs1 <= 4'b1111; r_Rs2 <= 4'b1010; //1111&1010
//     #240; r_Rs1 <= 4'b1110; r_Rs2 <= 4'b1011; //1110&1011
//     #252; r_ALUctl <= 4'b0001; r_Rs1 <= 4'b1011; r_Rs2 <= 4'b0010; //0001|1011
//     #265; r_Rs1 <= 6; r_Rs2 <= 5; //0110|0101
//     #368; r_ALUctl <= 4'b0010; r_Rs1 <= 4; r_Rs2 <= 111; //4+111
//     #543; r_Rs1 <= 42; r_Rs2 <= 19; //42+19
//     #614; r_ALUctl <= 4'b0110; r_Rs1 <= 6; r_Rs2 <= 5; //6-5
//     #620; r_Rs1 <= 6; r_Rs2 <= 6; //6-6

end

initial begin
    #10000;
    $finish;
end

endmodule