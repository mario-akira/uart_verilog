`timescale 1ns/1ps

module rx_uart_tb;

    localparam CLK_FREQ  = 50000000;   // 10 MHz (simulação mais rápida)
    localparam BAUD_RATE = 115200;

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam BIT_PERIOD   = CLKS_PER_BIT * 20;

    reg clk;
    reg rst;
    reg rx;

    wire [7:0] data_out;
    wire data_valid;
    wire busy;
    wire parity_error;
    wire frame_error;

    rx_uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .PARITY(0),
        .STOP_BITS(1)
    ) dut (
        .clk_IN(clk),
        .rst_IN(rst),
        .rx_IN(rx),

        .data_OUT(data_out),
        .data_valid_OUT(data_valid),
        .busy_OUT(busy),
        .parity_error_OUT(parity_error),
        .frame_error_OUT(frame_error)
    );

    // =========================
    // Clock 10 MHz → 100 ns
    // =========================
    always #10 clk = ~clk;

    // =========================
    // Inicialização
    // =========================
    initial begin	    
        $dumpfile("rx_uart.vcd");
        $dumpvars(0, rx_uart_tb);

        clk = 1;
        rst = 1;
        rx  = 1; // idle UART

        #200;
        rst = 0;

        // Enviar alguns bytes
        send_byte(8'h55); // 01010101
        #(BIT_PERIOD * 3);

        send_byte(8'hA3);
        #(BIT_PERIOD * 3);

        send_byte(8'hF0);
        #(BIT_PERIOD * 3);

        $finish;
    end

    task send_byte(input [7:0] data);
        integer i;
        begin
            rx = 0;
            #(BIT_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BIT_PERIOD);
            end

            // STOP bit
            rx = 1;
            #(BIT_PERIOD);
        end
    endtask

    // =========================
    // Monitor
    // =========================
    always @(posedge clk) begin
        if (data_valid) begin
            $display("Recebido: %h | parity_err=%b | frame_err=%b",
                     data_out, parity_error, frame_error);
        end
    end

endmodule

