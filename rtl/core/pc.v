//Program counter
`timescale 1ns/1ps

module pc (
    input i_Clock,
    input i_Reset,

    input i_Branch,
    input i_Zero,
    input [63:0] i_Immediate,

    output reg [63:0] o_PC
);

always @(posedge i_Clock) begin
    if(i_Reset == 1'b1) begin
        o_PC <= 64'b0;
    end else begin
        //PC + 4 || PC + Imm when branch
        o_PC <= (i_Branch & i_Zero) ? (o_PC + i_Immediate) : (o_PC + 4);
    end
end
endmodule