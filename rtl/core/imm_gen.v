//Immediate generation
`timescale 1ns/1ps

module imm_gen (
    input [31:0] i_Instr,

    output reg [63:0] o_Immediate
);

always @(*) begin
    //I-type always uses last 12 bits. Sign extend to 64 bits
    o_Immediate <= {20'b0, i_Instr [31:20]};
end
endmodule