`timescale 1ns/10ps
 
`include "../rtl/core/pc.v"
 
module pc_tb ();
parameter c_CLOCK_PERIOD_NS = 100;
reg r_Clock = 0;
reg r_Reset = 1;

reg r_Branch, r_Zero;
reg [63:0] r_Immediate;
wire [63:0] w_PC;
   
   
pc dut(
    .i_Clock(r_Clock),
    .i_Reset(r_Reset),
    .i_Branch(r_Branch),
    .i_Zero(r_Zero),
    .i_Immediate(r_Immediate),
    .o_PC(w_PC)
);
 
always #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
   
// Main Testing:
initial begin
    $dumpfile("../runs/pc_tb.vcd");
    $dumpvars(0,r_Clock,r_Reset, r_Branch, r_Zero, r_Immediate, w_PC);
    $display("Begin simulation");
    @(posedge r_Clock);
    r_Reset <= 0; r_Branch <= 0; r_Zero <= 0; r_Immediate <= 0;
end

initial begin
    #200000;
    $finish;
end

endmodule