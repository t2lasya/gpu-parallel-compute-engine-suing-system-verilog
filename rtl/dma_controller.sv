module dma_controller #(
    parameter int DATA_W = 32,
    parameter int ADDR_W = 8
) (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              start,
    output logic              busy,
    output logic              done,
    input  logic [ADDR_W-1:0] src_addr,
    input  logic [ADDR_W-1:0] dst_addr,
    input  logic [ADDR_W:0]   length_words,
    output logic              mem_en,
    output logic              mem_we,
    output logic [ADDR_W-1:0] mem_addr,
    output logic [DATA_W-1:0] mem_wdata,
    input  logic [DATA_W-1:0] mem_rdata,
    input  logic              mem_ready
);
    typedef enum logic [1:0] {IDLE, READ_WORD, WRITE_WORD} state_t;
    state_t state;
    logic [ADDR_W-1:0] src_q, dst_q;
    logic [ADDR_W:0] remaining;
    logic [DATA_W-1:0] data_q;

    always_comb begin
        mem_en = 1'b0;
        mem_we = 1'b0;
        mem_addr = '0;
        mem_wdata = data_q;
        case (state)
            READ_WORD: begin
                mem_en = 1'b1;
                mem_addr = src_q;
            end
            WRITE_WORD: begin
                mem_en = 1'b1;
                mem_we = 1'b1;
                mem_addr = dst_q;
                mem_wdata = data_q;
            end
            default: ;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            busy <= 1'b0;
            done <= 1'b0;
            src_q <= '0;
            dst_q <= '0;
            remaining <= '0;
            data_q <= '0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: if (start) begin
                    src_q <= src_addr;
                    dst_q <= dst_addr;
                    remaining <= length_words;
                    if (length_words == 0) begin
                        done <= 1'b1;
                        busy <= 1'b0;
                    end else begin
                        busy <= 1'b1;
                        state <= READ_WORD;
                    end
                end
                READ_WORD: if (mem_ready) begin
                    data_q <= mem_rdata;
                    state <= WRITE_WORD;
                end
                WRITE_WORD: if (mem_ready) begin
                    if (remaining == 1) begin
                        remaining <= '0;
                        busy <= 1'b0;
                        done <= 1'b1;
                        state <= IDLE;
                    end else begin
                        remaining <= remaining - 1'b1;
                        src_q <= src_q + 1'b1;
                        dst_q <= dst_q + 1'b1;
                        state <= READ_WORD;
                    end
                end
                default: begin
                    state <= IDLE;
                    busy <= 1'b0;
                end
            endcase
        end
    end
endmodule
