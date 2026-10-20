module round_robin_scheduler (
    input  logic clk,
    input  logic rst_n,
    input  logic req0,
    input  logic req1,
    output logic grant0,
    output logic grant1,
    input  logic grant_accept
);
    logic prefer1;

    always_comb begin
        grant0 = 1'b0;
        grant1 = 1'b0;
        if (req0 && req1) begin
            grant0 = !prefer1;
            grant1 =  prefer1;
        end else if (req0) begin
            grant0 = 1'b1;
        end else if (req1) begin
            grant1 = 1'b1;
        end
    end

    // After an accepted grant, prefer the other requester next time.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            prefer1 <= 1'b0;
        else if (grant_accept && (grant0 || grant1))
            prefer1 <= grant0;
    end
endmodule
