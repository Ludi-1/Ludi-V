module rv32i_sc (
    input wire clk,         // Clock input
    input wire reset,       // Reset input

    // Instruction inputs
    input wire [31:0] instruction,

    // Instruction outputs
    output wire [31:0] pc,

    // Data memory inputs
    input wire [31:0] data_in,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] mem_address,

    // Data memory outputs
    output wire [31:0] data_out,

    // Register file inputs
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire reg_write,

    // Register file outputs
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    // Registers
    reg [31:0] pc;
    reg [31:0] instruction_reg;
    reg [31:0] imm;
    reg [31:0] alu_result;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] rs1_data_reg;
    reg [31:0] rs2_data_reg;
    reg [31:0] rd_data_reg;
    reg [31:0] data_memory [0:1023];

    // Control signals
    reg mem_to_reg;
    reg reg_dst;
    reg alu_src;
    reg branch;
    reg mem_read_signal;
    reg mem_write_signal;
    reg [2:0] alu_op;
    reg reg_write_signal;

    // Fetch stage
    always @(posedge clk or posedge reset) begin
        if (reset)
        pc <= 0;
        else
        pc <= pc + 4;
        instruction_reg <= instruction;
    end

    // Decode stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        rs1 <= 0;
        rs2 <= 0;
        rd <= 0;
        end
        else begin
        rs1 <= instruction_reg[19:15];
        rs2 <= instruction_reg[24:20];
        rd <= instruction_reg[11:7];
        end
    end

    // Register file
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        rs1_data_reg <= 0;
        rs2_data_reg <= 0;
        rd_data_reg <= 0;
        end
        else begin
        rs1_data_reg <= rs1 == 0 ? 0 : data_memory[rs1];
        rs2_data_reg <= rs2 == 0 ? 0 : data_memory[rs2];
        rd_data_reg <= data_memory[rd];
        end
    end

    // Execute stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        imm <= 0;
        alu_result <= 0;
        mem_to_reg <= 0;
        reg_dst <= 0;
        alu_src <= 0;
        branch <= 0;
        mem_read_signal <= 0;
        mem_write_signal <= 0;
        alu_op <= 0;
        reg_write_signal <= 0;
        end
        else begin
        imm <= instruction_reg[31:20];
        alu_src <= instruction_reg[14];
        branch <= instruction_reg[6];
        mem_read_signal <= instruction_reg[14];
        mem_write_signal <= instruction_reg[13];
        reg_dst <= instruction_reg[12];
        alu_op <= instruction_reg[6:0];

        // ALU operations
        case (alu_op)
            7'b0000000: alu_result <= rs1_data_reg + rs2_data_reg; // ADD
            7'b0000001: alu_result <= rs1_data_reg - rs2_data_reg; // SUB
            7'b0000010: alu_result <= rs1_data_reg & rs2_data_reg; // AND
            7'b0000011: alu_result <= rs1_data_reg | rs2_data_reg; // OR
            7'b0000100: alu_result <= rs1_data_reg ^ rs2_data_reg; // XOR
            7'b0000101: alu_result <= rs1_data_reg << rs2_data_reg; // SLL
            7'b0000110: alu_result <= rs1_data_reg >> rs2_data_reg; // SRL
            7'b0000111: alu_result <= rs1_data_reg >>> rs2_data_reg; // SRA
            7'b0001000: alu_result <= rs1_data_reg < rs2_data_reg ? 1 : 0; // SLT
            7'b0001001: alu_result <= rs1_data_reg < rs2_data_reg ? 1 : 0; // SLTU
            default: alu_result <= 0;
        endcase
        end
    end

    // Memory stage
    always @(posedge clk or posedge reset) begin
        if (reset)
        data_out <= 0;
        else if (mem_read_signal)
        data_out <= data_memory[mem_address[9:2]];
        else if (mem_write_signal)
        data_memory[mem_address[9:2]] <= data_in;
    end

    // Write-back stage
    always @(posedge clk or posedge reset) begin
        if (reset)
        reg_write_signal <= 0;
        else if (reg_write)
        reg_write_signal <= 1;
        else
        reg_write_signal <= 0;
    end

    // Output register file data
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        rs1_data <= 0;
        rs2_data <= 0;
        end
        else begin
        rs1_data <= rs1_data_reg;
        rs2_data <= rs2_data_reg;
        end
    end

    // Update data register on write-back stage
    always @(posedge clk or posedge reset) begin
        if (reset)
        rd_data_reg <= 0;
        else if (reg_write_signal)
        rd_data_reg <= alu_result;
    end

    // Update register file on write-back stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        data_memory[0] <= 0; // Register x0 is always zero
        data_memory[1] <= 0; // Register x1 is reserved for the assembler
        end
        else if (reg_write_signal && rd != 0)
        data_memory[rd] <= rd_data_reg;
    end

endmodule