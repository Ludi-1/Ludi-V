`timescale 1ns/10ps
`include "../rtl/core/control.v"

module control_tb ();
reg [31:0] r_Instr = 0;
wire [3:0] w_ALUctl;
wire w_Branch, w_MemToReg, w_MemWrite, w_ALUsrc, w_RegWrite;
    
control dut(
    .i_Instr(r_Instr),
    .o_ALUctl(w_ALUctl),
    .o_Branch(w_Branch),
    .o_MemToReg(w_MemToReg),
    .o_MemWrite(w_MemWrite),
    .o_ALUsrc(w_ALUsrc),
    .o_RegWrite(w_RegWrite)
);
   
// Main Testing:
initial begin
    $dumpfile("../runs/control_tb.vcd");
    $dumpvars(0, r_Instr, w_ALUctl, w_Branch, w_MemToReg, w_MemWrite, w_ALUsrc, w_RegWrite);
    $display("Begin simulation");
    #200; r_Instr <= 32'b00000_00_00001_00010_000_00011_01100_11;

end

initial begin
    #10000;
    $finish;
end

endmodule