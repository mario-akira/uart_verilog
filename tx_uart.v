/*
Author: Mario Akira
Date:03/2026
*/
module tx_uart #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200,
    parameter STOP_BITS = 2'h1,           // 1 ou 2
    parameter PARITY    = 1'b0       // "NONE"=0, "EVEN"=1, "ODD"=2
)(
	input 	wire 			clk_IN,
	input 	wire 			rst_IN,

	input 	wire [7:0] 	data_IN,
	input 	wire 			enable_IN,

	output 	reg 			tx_OUT,
	output 	reg 			busy_OUT
);
//=======================================================
//  Local parameters declarations
//=======================================================
	localparam 	CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
	localparam	idle=2'h0,word_build=2'h1,sending_word=2'h2; 
//=======================================================
//  Refisters declarations
//=======================================================
	reg [11:0] 	tx_shift = 12'hFFF;
	reg [15:0] 	clk_count = 16'h0;
	reg [3:0] 	bit_index = 4'h0;
	reg [3:0] 	total_bits = 4'h0;
	reg [7:0]	data_reg;
	reg 			sending = 1'h0;
	reg 			parity_bit;
	reg [2:0]	next_state;
	reg 			parity_end = 1'b0;
//=======================================================
//  Wire declarations
//=======================================================

//=======================================================
//  Structural coding
//=======================================================
always @(posedge clk_IN) begin
        if (rst_IN) begin
            next_state <= idle;
            tx_OUT <= 1'b1;
            busy_OUT <= 1'b0;
            clk_count <= 16'h0;
            bit_index <= 4'h0;
            tx_shift <= 12'hFFF;
            parity_bit <= 1'b0;
        end 
		  else begin
            case (next_state)
                idle: begin
                    tx_OUT <= 1'b1;
                    busy_OUT <= 1'b0;

                    if (enable_IN) begin
                        data_reg <= data_IN;
                        busy_OUT <= 1'b1;
                        next_state <= word_build;
                    end
						  else begin
								next_state <= idle;
						  end
                end

                // -----------------
                word_build: begin
                    if (PARITY == 2'h1) begin
                        parity_bit <= ^data_reg;
                    end else if (PARITY == 2'h2) begin
                        parity_bit <= ~(^data_reg);
                    end else begin
                        parity_bit <= 1'b0;
                    end
                    if (PARITY == 0) begin
                        tx_shift <= { {STOP_BITS{1'b1}}, data_reg, 1'b0 };
                        total_bits <= 4'h1 + 4'h8 + STOP_BITS;
                    end else begin
                        tx_shift <= { {STOP_BITS{1'b1}}, parity_bit, data_reg, 1'b0 };
                        total_bits <= 4'h1 + 4'h8 + 4'h1 + STOP_BITS;
                    end
                    clk_count <= 16'h0;
                    bit_index <= 4'h0;
                    next_state <= sending_word;
                end
                sending_word: begin
                    if (clk_count < CLKS_PER_BIT - 1'b1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= 16'h0;
                        tx_OUT <= tx_shift[0];
                        tx_shift <= {1'b1, tx_shift[11:1]};
                        if (bit_index < total_bits - 1) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            next_state <= idle;
                        end
                    end
                end

            endcase
        end
    end
endmodule
