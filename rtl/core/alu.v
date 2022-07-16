//ALU
`timescale 1ns/1ps

module alu (
    input [3:0] i_ALUctl, //ALU control
    input [63:0] i_Rs1, i_Rs2, //Data register
    input [63:0] i_Immediate, //Immediate value
    input i_ALUsrc, //Select Rs2 or Imm

    output reg [63:0] o_Result, //Result
    output reg o_Zero //Zero flag
);

reg [63:0] r_Rs2;

always @(*) begin
    r_Rs2 <= i_ALUsrc ? i_Immediate : i_Rs2;
    o_Zero <= (o_Result == 0);

    case(i_ALUctl)
        4'h0: o_Result <= i_Rs1 & r_Rs2; //and
        4'h1: o_Result <= i_Rs1 | r_Rs2; //or
        4'h2: o_Result <= i_Rs1 ^ r_Rs2; //xor
        4'h3: o_Result <= i_Rs1 + r_Rs2; //add
        4'h4: o_Result <= i_Rs1 << r_Rs2[4:0]; //logical left shift
        4'h5: o_Result <= i_Rs1 >> r_Rs2[4:0]; //logical right shift
        4'h6: o_Result <= i_Rs1 >>> r_Rs2[4:0];
        4'h7: o_Result <= i_Rs1 + r_Rs2; //add
        4'h8: o_Result <= i_Rs1 - r_Rs2; //sub
        4'h9: o_Result <= i_Rs1 < r_Rs2 ? 1 : 0; //set less than
        4'hA: o_Result <= ~(i_Rs1 | r_Rs2); //nor
        default: o_Result <= 0;
    endcase
end
endmodule