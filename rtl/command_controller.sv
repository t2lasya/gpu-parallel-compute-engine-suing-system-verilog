module command_controller #(
    parameter int DATA_W = 32
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 cmd_valid,
    output logic                 cmd_ready,
    input  logic [2:0]           cmd_op,
    input  logic [DATA_W-1:0]    cmd_a,
    input  logic [DATA_W-1:0]    cmd_b,
    input  logic [DATA_W-1:0]    cmd_c,
    output logic                 dispatch_valid,
    input  logic                 dispatch_ready,
    output logic [2:0]           dispatch_op,
    output logic [DATA_W-1:0]    dispatch_a,
    output logic [DATA_W-1:0]    dispatch_b,
    output logic [DATA_W-1:0]    dispatch_c
);
    logic full;
    logic [2:0]        op_q;
    logic [DATA_W-1:0] a_q, b_q, c_q;

    assign cmd_ready      = !full || dispatch_ready;
    assign dispatch_valid = full;
    assign dispatch_op    = op_q;
    assign dispatch_a     = a_q;
    assign dispatch_b     = b_q;
    assign dispatch_c     = c_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full <= 1'b0;
            op_q <= '0;
            a_q  <= '0;
            b_q  <= '0;
            c_q  <= '0;
        end else if (cmd_ready) begin
            full <= cmd_valid;
            if (cmd_valid) begin
                op_q <= cmd_op;
                a_q  <= cmd_a;
                b_q  <= cmd_b;
                c_q  <= cmd_c;
            end
        end
    end
endmodule
