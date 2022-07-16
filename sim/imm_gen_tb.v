`timescale 1ns/10ps
 
`include "../rtl/core/imm_gen.v"
 
module imm_gen_tb ();

reg [31:0] r_Instr;
wire [63:0] w_Immediate;
   
imm_gen dut(
    .i_Instr(r_Instr),
    .o_Immediate(w_Immediate)
);
   
// Main Testing:
initial begin
    $dumpfile("../runs/imm_gen_tb.vcd");
    $dumpvars(0,r_Instr,w_Immediate);
    $display("Begin simulation");
    #200; r_Instr <= 32'hFFFFFFFF;
    #200; r_Instr <= 32'hABCDFFFF;
    #200; r_Instr <= 32'hDABCFFFF;
    #200; r_Instr <= 32'hCDABFFFF;
    #200; r_Instr <= 32'hBCDAFFFF;
    #200; r_Instr <= 32'hABCDFFFF;
end

initial begin
    #200000;
    $finish;
end

endmodule