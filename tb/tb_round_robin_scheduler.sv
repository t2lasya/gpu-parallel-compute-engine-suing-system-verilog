module tb_round_robin_scheduler;
    logic clk=0, rst_n=0, req0, req1, grant0, grant1, grant_accept;
    always #5 clk = ~clk;
    round_robin_scheduler dut(.*);

    initial begin
        req0=0; req1=0; grant_accept=0;
        repeat (2) @(posedge clk);
        rst_n=1;
        @(negedge clk); req0=1; req1=1;
        #1;
        if (!(grant0 && !grant1)) $fatal(1, "Expected first tie to grant unit 0");
        grant_accept=1;
        @(negedge clk); #1;
        if (!(grant1 && !grant0)) $fatal(1, "Expected second tie to grant unit 1");
        grant_accept=1;
        @(negedge clk); #1;
        if (!(grant0 && !grant1)) $fatal(1, "Expected third tie to grant unit 0");
        $display("PASS: round-robin scheduler alternates simultaneous requests");
        $finish;
    end
endmodule
