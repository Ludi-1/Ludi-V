//Instruction memory
`timescale 1ns/1ps

module instr (
    input i_Clock,
    input i_Reset,

    input [63:0] i_PC,

    output reg [31:0] o_Instr
);

always @(*) begin
    if(i_Reset == 1'b1) begin
        o_Instr <= 32'b0;
    end else begin
        case(i_PC)
            //ADDI 1, 1, 7
            64'h0000_0000_0000_0000: o_Instr <= 32'b000000000111_00001_000_00001_00100_11;
            //ADDI 2, 2, 5
            64'h0000_0000_0000_0004: o_Instr <= 32'b000000000101_00010_000_00010_00100_11;
            //ADD 3, 1, 2
            64'h0000_0000_0000_0008: o_Instr <= 32'b00000_00_00001_00010_000_00011_01100_11;
            default: o_Instr = 0;
        endcase
    end
end
endmodule
