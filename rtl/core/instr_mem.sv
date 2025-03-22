module instr_mem (
    input wire [31:0] address,
    output reg [31:0] instr
);

    reg [7:0] mem [0:1023];

    // Initialize memory with instructions
    initial begin
        $readmemh("src/hello_world.hex", mem);
        // $readmemh("hello_world.hex", mem);
    end

    // Read instruction from memory based on address
    always_comb begin
        instr = {mem[address+3], mem[address+2], mem[address+1], mem[address]};
    end

endmodule
