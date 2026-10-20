module shared_memory #(
    parameter int DATA_W = 32,
    parameter int ADDR_W = 8,
    parameter int DEPTH  = 256
) (
    input  logic              clk,
    input  logic              en,
    input  logic              we,
    input  logic [ADDR_W-1:0] addr,
    input  logic [DATA_W-1:0] wdata,
    output logic [DATA_W-1:0] rdata
);
    logic [DATA_W-1:0] mem [0:DEPTH-1];

    // Synchronous single-port RAM. Out-of-range addresses are not supported.
    always_ff @(posedge clk) begin
        if (en) begin
            if (we)
                mem[addr] <= wdata;
            rdata <= mem[addr];
        end
    end
endmodule
