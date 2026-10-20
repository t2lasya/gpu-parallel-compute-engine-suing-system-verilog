module parallel_compute_top #(
    parameter int DATA_W = 32
) (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              cmd_valid,
    output logic              cmd_ready,
    input  logic [2:0]        cmd_op,
    input  logic [DATA_W-1:0] cmd_a,
    input  logic [DATA_W-1:0] cmd_b,
    input  logic [DATA_W-1:0] cmd_c,
    output logic              result_valid,
    input  logic              result_ready,
    output logic [DATA_W-1:0] result_data,
    output logic              result_unit,
    input  logic              perf_clear,
    output logic [31:0]       perf_cycles,
    output logic [31:0]       perf_stalls,
    output logic [31:0]       perf_completed
);
    logic d_valid, d_ready;
    logic [2:0] d_op;
    logic [DATA_W-1:0] d_a, d_b, d_c;
    logic rr_g0, rr_g1;
    logic cu0_in_valid, cu1_in_valid, cu0_in_ready, cu1_in_ready;
    logic cu0_out_valid, cu1_out_valid;
    logic [DATA_W-1:0] cu0_result, cu1_result;
    logic choose1_q, result_valid_i;
    logic [DATA_W-1:0] result_i;
    logic busy_i, stall_i, task_done_i;

    command_controller #(.DATA_W(DATA_W)) u_cmd (
        .clk, .rst_n, .cmd_valid, .cmd_ready, .cmd_op, .cmd_a, .cmd_b, .cmd_c,
        .dispatch_valid(d_valid), .dispatch_ready(d_ready),
        .dispatch_op(d_op), .dispatch_a(d_a), .dispatch_b(d_b), .dispatch_c(d_c)
    );

    round_robin_scheduler u_sched (
        .clk, .rst_n,
        .req0(d_valid && cu0_in_ready), .req1(d_valid && cu1_in_ready),
        .grant0(rr_g0), .grant1(rr_g1), .grant_accept(d_valid && d_ready)
    );

    // Both compute units are ready whenever their result slot can accept work.
    assign cu0_in_valid = d_valid && d_ready && rr_g0;
    assign cu1_in_valid = d_valid && d_ready && rr_g1;
    assign d_ready = (rr_g0 && cu0_in_ready) || (rr_g1 && cu1_in_ready);

    compute_unit #(.DATA_W(DATA_W)) u_cu0 (
        .clk, .rst_n, .in_valid(cu0_in_valid), .in_ready(cu0_in_ready),
        .in_op(d_op), .in_a(d_a), .in_b(d_b), .in_c(d_c),
        .out_valid(cu0_out_valid), .out_ready(result_ready && !choose1_q),
        .out_result(cu0_result)
    );
    compute_unit #(.DATA_W(DATA_W)) u_cu1 (
        .clk, .rst_n, .in_valid(cu1_in_valid), .in_ready(cu1_in_ready),
        .in_op(d_op), .in_a(d_a), .in_b(d_b), .in_c(d_c),
        .out_valid(cu1_out_valid), .out_ready(result_ready && choose1_q),
        .out_result(cu1_result)
    );

    // Preserve the source-unit tag while a result is held under backpressure.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            choose1_q <= 1'b0;
        else if (d_valid && d_ready)
            choose1_q <= rr_g1;
        else if (result_valid && result_ready)
            choose1_q <= 1'b0;
    end

    always_comb begin
        result_valid_i = 1'b0;
        result_i = '0;
        if (choose1_q) begin
            result_valid_i = cu1_out_valid;
            result_i = cu1_result;
        end else begin
            result_valid_i = cu0_out_valid;
            result_i = cu0_result;
        end
    end
    assign result_valid = result_valid_i;
    assign result_data = result_i;
    assign result_unit = choose1_q;

    assign busy_i = d_valid || cu0_out_valid || cu1_out_valid;
    assign stall_i = cmd_valid && !cmd_ready;
    assign task_done_i = result_valid && result_ready;

    performance_counters u_perf (
        .clk, .rst_n, .clear(perf_clear), .busy(busy_i), .stall(stall_i),
        .task_done(task_done_i), .cycle_count(perf_cycles),
        .stall_count(perf_stalls), .completed_count(perf_completed)
    );
endmodule
