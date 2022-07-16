//Data memory: Store data
`timescale 1ns/1ps

module data_mem (
    input i_Clock,
    input i_Reset,

    input i_MemWrite,
    input [63:0] i_Address, i_Data,

    output reg [63:0] o_ReadData
);

reg [63:0] r_Reg [63:0];
integer i;

always @(posedge i_Clock) begin
    if(i_Reset == 1'b1) begin  
        for (i = 0; i < 64; i = i + 1) begin
            //Initialize every register at 0
            r_Reg [i] = 0; 
        end 
    end else begin
        if (i_MemWrite == 1) begin
            r_Reg[i_Address] <= i_Data;
        end else begin
            r_Reg[i_Address] <= r_Reg[i_Address];
        end
    end
    o_ReadData <= r_Reg[i_Address];
end
endmodule