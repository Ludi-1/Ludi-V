module stage_memory (
    input wire clk,

    // RD passthrough
    input wire [4:0] execute_rd,
    output reg [4:0] mem_rd,

    // Register file write enable passthrough
    input wire execute_regfile_wr_enable,
    output reg mem_regfile_wr_enable,

    // ALU result (passthrough)
    input wire [31:0] execute_alu_result,
    output reg [31:0] mem_alu_result,

    // PC + 4 passthrough
    input wire [31:0] execute_instr_addr_plus,
    output reg [31:0] mem_instr_addr_plus,

    // ResultSrc (ALU/datamem/PCplus) passthrough
    input wire [1:0] execute_result_src,
    output reg [1:0] mem_result_src,

    input wire execute_datamem_wr_enable,
    input wire [2:0] execute_funct3,
    input wire [31:0] execute_wr_datamem_data,
    output reg [31:0] mem_rd_datamem_data
);

reg [7:0] data_memory [127:0]; // 128 B data mem
wire [31:0] datamem_data;
wire [6:0] data_mem_addr_0, data_mem_addr_1, data_mem_addr_2, data_mem_addr_3; // log2(128)
assign data_mem_addr_0 = execute_alu_result[6:0];
assign data_mem_addr_1 = data_mem_addr_0 + 1;
assign data_mem_addr_2 = data_mem_addr_0 + 2;
assign data_mem_addr_3 = data_mem_addr_0 + 3;
assign datamem_data = execute_wr_datamem_data;

always_ff @(posedge clk) begin
    if (execute_datamem_wr_enable) begin
        data_memory[data_mem_addr_0] <= datamem_data[7:0];
        case (execute_funct3[1:0])
            2'b01: begin
                data_memory[data_mem_addr_1] <= datamem_data[15:8];
            end
            2'b10: begin
                data_memory[data_mem_addr_1] <= datamem_data[15:8];
                data_memory[data_mem_addr_2] <= datamem_data[23:16];
                data_memory[data_mem_addr_3] <= datamem_data[31:24];
            end
        endcase
    end
    case (execute_funct3)
        3'b000: mem_rd_datamem_data <= {{24{data_memory[data_mem_addr_0][7]}}, data_memory[data_mem_addr_0]};
        3'b001: mem_rd_datamem_data <= {{16{data_memory[data_mem_addr_1][7]}}, data_memory[data_mem_addr_1], data_memory[data_mem_addr_0]};
        3'b010: begin
            mem_rd_datamem_data <= {
                data_memory[data_mem_addr_3],
                data_memory[data_mem_addr_2],
                data_memory[data_mem_addr_1],
                data_memory[data_mem_addr_0]
            };
        end
        3'b100: begin
            mem_rd_datamem_data <= {24'b0, data_memory[data_mem_addr_0]}; // LBU
        end
        3'b101: begin
            mem_rd_datamem_data <= {16'b0, data_memory[data_mem_addr_1], data_memory[data_mem_addr_0]}; // LHU
        end
        default: begin
            mem_rd_datamem_data <= {
                data_memory[data_mem_addr_3],
                data_memory[data_mem_addr_2],
                data_memory[data_mem_addr_1],
                data_memory[data_mem_addr_0]
            };
        end
    endcase
    mem_alu_result <= execute_alu_result;
    mem_rd <= execute_rd;
    mem_regfile_wr_enable <= execute_regfile_wr_enable;
    mem_instr_addr_plus <= execute_instr_addr_plus;
    mem_result_src <= execute_result_src;
end

initial begin
    for (integer i = 0; i < 128; i = i + 1) $dumpvars(0, data_memory[i]);
end

endmodule