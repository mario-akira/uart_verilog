# uart_verilog
Verilog Universal asynchronous receiver-transmitter (UART) implementation with transceiver and reeiver modules

The modules are located in the "modules" folder, and the simulation files are in "tb".

To simulate tx_uart.v with tx_uart_tb.v:
  iverilog -o tx_uart_tb tx_uart_tb.v ../modules/tx_uart.v
  vvp tx_uart_tb
  gtkwave uart_tx.vcd
