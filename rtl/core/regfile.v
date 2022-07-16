//Register file: Holds all registers
`timescale 1ns/1ps

module regfile (
    input i_Clock,
    input i_Reset,

    input [4:0] i_ReadReg1, i_ReadReg2, i_WriteReg,
    input i_MemToReg, i_RegWrite,
    input [63:0] i_ReadData, i_ALUresult, //From data memory / ALU

    output reg [63:0] o_Data1, o_Data2
);

reg [63:0] r_Reg [4:0];
reg [63:0] r_WriteData;
integer i;

always @(r_Reg[i_ReadReg1], r_Reg[i_ReadReg2], i_ReadReg1, i_ReadReg2, i_MemToReg, i_ReadData, i_ALUresult) begin
    //i_MemToReg: Direct ALU result or Data memory to Register file
    r_WriteData <= i_MemToReg ? i_ReadData : i_ALUresult; 
    o_Data1 <= r_Reg[i_ReadReg1];
    o_Data2 <= r_Reg[i_ReadReg2];
end

always @(posedge i_Clock)
    begin
        if(i_Reset == 1'b1) begin  
            for (i = 0; i < 32; i = i + 1) begin
                //Initialize every register at 0
                r_Reg [i] = 0; 
            end 
        end else begin
            //Register 0 is always 0
            if ((i_RegWrite == 1) & (i_WriteReg != 0)) begin
                r_Reg[i_WriteReg] <= r_WriteData;
            end else begin
                r_Reg[i_WriteReg] <= r_Reg[i_WriteReg];
            end
        end
    end
endmodule