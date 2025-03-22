module bram #(
  parameter int ADDR_WIDTH = 10,   // 2^10 = 1024 locations
  parameter int DATA_WIDTH = 32    // 32-bit data width
)(
  input logic clk,
  input logic we,                  // Write Enable
  input logic [ADDR_WIDTH-1:0] addr, // Address
  input logic [DATA_WIDTH-1:0] din,  // Write Data
  output logic [DATA_WIDTH-1:0] dout // Read Data
);

  // BRAM Memory Array
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

  always_ff @(posedge clk) begin
    if (we) begin
      mem[addr] <= din; // Write
    end
    dout <= mem[addr];  // Read (Synchronous)
  end

endmodule
