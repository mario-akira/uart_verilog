# uart_verilog
Verilog Universal asynchronous receiver-transmitter (UART) implementation with transceiver and reeiver modules

The modules are located in the "modules" folder, and the simulation files are in "tb".

rx_uart.v created, but not simulated yet.

To simulate tx_uart.v with tx_uart_tb.v:

>iverilog -o tx_uart_tb tx_uart_tb.v ../modules/tx_uart.v

>vvp tx_uart_tb

>gtkwave uart_tx.vcd

To simulate rx_uart.v with rx_uart_tb.v:

>iverilog -o rx_tb rx_uart_tb.v ../modules/rx_uart.v

>vvp rx_tb

>gtkwave rx_uart.vcd
