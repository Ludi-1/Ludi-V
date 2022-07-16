//Control unit
`timescale 1ns/1ps

module control (
    input [31:0] i_Instr,

    output reg [3:0] o_ALUctl,
    output reg o_Branch, o_MemToReg, o_MemWrite, o_ALUsrc, o_RegWrite
);

wire [6:0] w_OpCode = i_Instr [6:0]; //opcode
wire [2:0] w_Funct3 = i_Instr [14:12]; //funct3
wire [6:0] w_Funct7 = i_Instr [31:25]; //funct7

always @(*)
begin
    case(w_OpCode)
        7'b01100_11: begin //R-type
            //RV32I: ADD*, SUB*, SLL, SLT, SLTU, XOR, SRL, SRA, OR*, AND*
            //RV64I: SLLIW, SRLIW, SRAIW, ADDW, SUBW, SLLW, SRLW, SRAW
            o_Branch <= 0;
            o_MemToReg <= 0;
            o_MemWrite <= 0;
            o_ALUsrc <= 0;
            o_RegWrite <= 1;
            case({w_Funct7, w_Funct3})
                10'b0000000_000: begin //ADD
                    o_ALUctl <= 4'b0010;
                end
                10'b0100000_000: begin
                    o_ALUctl <= 4'b0110; //SUB
                end
                default: begin
                    o_ALUctl <= 4'b0000;
                end
            endcase
        end
        7'b00000_11, 7'b00100_11: begin //I-type
            //RV32I: LB, LH, LW, LBU, LHU, ADDI*, SLTI, SLTIU, XORI, ORI, ANDI
            //RV64I: LWU, LD, ADDIW
            case(w_Funct3)
                3'b000: begin //ADDI
                    o_ALUctl <= 4'b0010; //add
                end
                3'b110: begin //ORI
                    o_ALUctl <= 4'b0001;
                end
                default: begin
                    o_ALUctl <= 4'b0000;
                end
            endcase
            o_ALUctl <= 4'b0010;
            o_Branch <= 0;
            o_MemToReg <= 0;
            o_MemWrite <= 0;
            o_ALUsrc <= 1;
            o_RegWrite <= 1;
        end
        7'b01000_11: begin //S-type
            //RV32I: SB, SH, SW
            //RV64I: SD
            o_ALUctl <= 4'b0010; 
            o_Branch <= 0;
            o_MemToReg <= 0;
            o_MemWrite <= 1;
            o_ALUsrc <= 0;
            o_RegWrite <= 0;
        end
        7'b11000_11: begin //B-type conditional branch, opcode = 99, ex. BEQ, BNE
            o_ALUctl <= 4'b0100;
            o_Branch <= 1;
            o_MemToReg <= 0;
            o_MemWrite <= 0;
            o_ALUsrc <= 0;
            o_RegWrite <= 0;
        end
        7'b0110111: begin //U-type RV32I: LUI
            o_ALUctl <= 4'b0010; 
            o_Branch <= 0;
            o_MemToReg <= 0;
            o_MemWrite <= 1;
            o_ALUsrc <= 0;
            o_RegWrite <= 0;
        end
        7'b0010111: begin //U-type RV32I: AUIPC
            o_ALUctl <= 4'b0010; 
            o_Branch <= 0;
            o_MemToReg <= 0;
            o_MemWrite <= 1;
            o_ALUsrc <= 0;
            o_RegWrite <= 0;
        end
        // 7'b1110011: ; //J-type?
        default: begin
            o_ALUctl <= 4'b0000;
            o_Branch <= 0;
            o_MemToReg <= 0;
            o_MemWrite <= 0;
            o_ALUsrc <= 0;
            o_RegWrite <= 0;
        end
    endcase
end
endmodule