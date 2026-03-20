module rx_uart #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200,
    parameter PARITY    = 0,  // 0=NONE, 1=EVEN, 2=ODD
    parameter STOP_BITS = 1   // 1 ou 2
)(
    input  wire       clk_IN,
    input  wire       rst_IN,
    input  wire       rx_IN,

    output reg [7:0]  data_OUT,
    output reg        data_valid_OUT,
    output reg        busy_OUT,
    output reg        parity_error_OUT,
    output reg        frame_error_OUT
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT     = CLKS_PER_BIT / 2;

    localparam idle  = 3'h0;
    localparam search_start = 3'h1;
    localparam reading_data  = 3'h2;
    localparam parity_search   = 3'h3;
    localparam build_word  = 3'h4;
    localparam finish  = 3'h5;
    reg [2:0] state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0] data_reg;
    reg parity_calc;
    reg parity_bit_rx;
    reg [1:0] stop_count;
	 
    always @(posedge clk_IN) begin
        if (rst_IN) begin
            state <= idle;
            clk_count <= 0;
            bit_index <= 0;
            data_reg <= 0;
            data_OUT <= 0;
            data_valid_OUT <= 0;
            busy_OUT <= 0;
            parity_error_OUT <= 0;
            frame_error_OUT <= 0;
            stop_count <= 0;
        end else begin

            case (state)
                idle: begin
                    data_valid_OUT <= 0;
                    busy_OUT <= 0;
                    parity_error_OUT <= 0;
                    frame_error_OUT <= 0;
                    if (rx_IN == 0) begin
                        busy_OUT <= 1;
                        clk_count <= 0;
                        state <= search_start;
                    end
                end
                search_start: begin
                    if (clk_count < HALF_BIT) begin
                        clk_count <= clk_count + 1;
                    end 
						  else begin
                        clk_count <= 0;
                        if (rx_IN == 0) begin
                            bit_index <= 0;
                            parity_calc <= 0;
                            state <= reading_data;
                        end else begin
                            state <= idle;
                        end
                    end
                end
                reading_data: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        data_reg[bit_index] <= rx_IN;
                        parity_calc <= parity_calc ^ rx_IN;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            if (PARITY == 0)
                                state <= build_word;
                            else
                                state <= parity_search;
                        end
                    end
                end
                parity_search: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        parity_bit_rx <= rx_IN;
                        if (PARITY == 1)
                            parity_error_OUT <= (parity_calc != rx_IN);
                        else
                            parity_error_OUT <= (parity_calc == rx_IN);
                        state <= build_word;
                        stop_count <= 0;
                    end
		end
                build_word: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (rx_IN != 1)
                            frame_error_OUT <= 1;
                        if (stop_count < STOP_BITS - 1) begin
                            stop_count <= stop_count + 1;
                        end else begin
                            data_OUT <= data_reg;
                            data_valid_OUT <= 1;
                            state <= finish;
                        end
                    end
                end
                finish: begin
                    state <= idle;
                end
            endcase
        end
    end

endmodule

