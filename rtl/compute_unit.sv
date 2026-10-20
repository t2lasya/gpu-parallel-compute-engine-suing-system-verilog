module compute_unit #(
    parameter int DATA_W = 32
) (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              in_valid,
    output logic              in_ready,
    input  logic [2:0]        in_op,
    input  logic [DATA_W-1:0] in_a,
    input  logic [DATA_W-1:0] in_b,
    input  logic [DATA_W-1:0] in_c,
    output logic              out_valid,
    input  logic              out_ready,
    output logic [DATA_W-1:0] out_result
);
    logic full;
    logic [DATA_W-1:0] result_q;
    logic [2*DATA_W-1:0] product;

    always_comb begin
        product = in_a * in_b;
        case (in_op)
            3'd0: out_result = result_q; // output is overridden below when input is accepted
            default: out_result = result_q;
        endcase
    end

    function automatic logic [DATA_W-1:0] calc(
        input logic [2:0] op,
        input logic [DATA_W-1:0] a,
        input logic [DATA_W-1:0] b,
        input logic [DATA_W-1:0] c
    );
        logic [2*DATA_W-1:0] p;
        begin
            p = a * b;
            case (op)
                3'd0: calc = a + b;
                3'd1: calc = a - b;
                3'd2: calc = p[DATA_W-1:0];
                3'd3: calc = p[DATA_W-1:0] + c;
                3'd4: calc = a ^ b;
                3'd5: calc = a & b;
                3'd6: calc = a | b;
                default: calc = a;
            endcase
        end
    endfunction

    assign in_ready = !full || out_ready;
    assign out_valid = full;
    assign out_result = result_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full <= 1'b0;
            result_q <= '0;
        end else if (in_ready) begin
            full <= in_valid;
            if (in_valid)
                result_q <= calc(in_op, in_a, in_b, in_c);
        end
    end
endmodule
