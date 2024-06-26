module instruction_memory (
    input wire [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] mem [0:2];

    // Initialize memory with instructions
    initial begin
        // Load instructions from a file or initialize manually
        // Example: Load instructions from a file named "instructions.txt"
        $readmemh("instructions.txt", mem);
    end

    // Read instruction from memory based on address
    always @(address) begin
        instruction <= mem[address>>2];
    end

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("vcd/instruction_memory.vcd");
    $dumpvars (0, address, instruction);
    #1;
    end
    `endif

endmodule