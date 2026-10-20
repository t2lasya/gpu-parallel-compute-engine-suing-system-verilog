module performance_counters #(
    parameter int COUNT_W = 32
) (
    input logic clk,
    input logic rst_n,
    input logic clear,
    input logic busy,
    input logic stall,
    input logic task_done,
    output logic [COUNT_W-1:0] cycle_count,
    output logic [COUNT_W-1:0] stall_count,
    output logic [COUNT_W-1:0] completed_count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count <= '0;
            stall_count <= '0;
            completed_count <= '0;
        end else if (clear) begin
            cycle_count <= '0;
            stall_count <= '0;
            completed_count <= '0;
        end else begin
            if (busy)
                cycle_count <= cycle_count + 1'b1;
            if (stall)
                stall_count <= stall_count + 1'b1;
            if (task_done)
                completed_count <= completed_count + 1'b1;
        end
    end
endmodule
