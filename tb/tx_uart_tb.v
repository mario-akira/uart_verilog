`timescale 1ns/1ns

module tx_uart_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;

    wire tx;
    wire busy;

    // module call
    tx_uart #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(115200),
        .STOP_BITS(1),
        .PARITY(0)
    ) uut (
        .clk_IN(clk),
        .rst_IN(rst),
        .data_IN(data_in),
        .enable_IN(start),
        .tx_OUT(tx),
        .busy_OUT(busy)
    );

    // Clock 50MHz
    initial begin
	clk = 1'b1;
	forever #10 clk=~clk;
    end

    initial begin
        // GTKWave files
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tx_uart_tb);

        // Initial data
        rst = 1;
        start = 0;
        data_in = 8'h00;

        #200;
        rst = 0;

        // Envia 0x55 (01010101)
        send_byte(8'h55);

        #200000;

        // Envia 0xA3
        send_byte(8'hA3);

        #200000;

        $finish;
    end

    // Task para enviar byte
    task send_byte(input [7:0] data);
    begin
        @(posedge clk);
        data_in <= data;
        start <= 1;

        @(posedge clk);
        start <= 0;

        // espera terminar transmissão
        wait (busy == 0);
    end
    endtask

endmodule
