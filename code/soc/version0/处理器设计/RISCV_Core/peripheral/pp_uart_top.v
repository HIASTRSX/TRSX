
module pp_uart_top(
  input        clk,
  input        rst,
  input        soft_rst,
  input             uart_tx_fifo_empty,
  input             uart_rx_fifo_full,
  input  [7:0]      uart_tx_fifo_data,
  output reg [7:0]  uart_rx_fifo_data,
  output reg        uart_rx_fifo_wreq,
  output            uart_tx_fifo_rreq,
  
  input             uart_rx,
  output            uart_tx,
  //output            uart_clk,
  // Configuration
  input  [13:0]     uart_baud,     //aurt_baud = clk/uart_clk
  input  [1:0]      data_flag,     //00:5bits,01:6bits,10:7bits,11:8bits
  input             stop_flag,     //0 :1bit,1:2bits
  input  [1:0]      check_flag,    //00:without,01:odd,10:even,11:reserve
  output [1:0]      parity_err     //00:no error ,01:odd check error, 10: even check error,11:reserve
);

  reg        xmitH;
  wire [7:0] xmit_dataH;
  wire       xmit_doneH;
  wire [7:0] rec_dataH;
  wire       rec_readyH;

  
  assign uart_tx_fifo_rreq = !uart_tx_fifo_empty && xmit_doneH && !xmitH;
  assign xmit_dataH = uart_tx_fifo_data;
  
  always @(posedge clk or negedge rst)
  if(!rst)
    xmitH <= 1'b0;
  else
    xmitH <= uart_tx_fifo_rreq;
  
  always @(posedge clk or negedge rst)
  if(!rst)
    uart_rx_fifo_wreq <= 1'b0;
  else if(!soft_rst)
    uart_rx_fifo_wreq <= 1'b0;
  else if(rec_readyH && !uart_rx_fifo_full)
    uart_rx_fifo_wreq <= 1'b1;
  else
    uart_rx_fifo_wreq <= 1'b0;
    
  always @(posedge clk or negedge rst)
  if(!rst)
    uart_rx_fifo_data <= 8'b0;
  else if(!soft_rst)
    uart_rx_fifo_data <= 8'b0;
  else if(rec_readyH && !uart_rx_fifo_full)
    uart_rx_fifo_data <= rec_dataH;
  else
    uart_rx_fifo_data <= 8'b0;
    
  
  
pp_uart_transceiver pp_uart_transceiver(      
        .clk            (clk),
        .rst            (rst),
        .soft_rst       (soft_rst),
        .uart_baud      (uart_baud),
        .uart_XMIT_dataH(uart_tx),
        .xmitH          (xmitH),
        .xmit_dataH     (xmit_dataH),
        .xmit_doneH     (xmit_doneH),
        .uart_REC_dataH (uart_rx),
        .rec_dataH      (rec_dataH),
        .rec_readyH     (rec_readyH),
        .data_flag      (data_flag),
        .stop_flag      (stop_flag),
        .check_flag     (check_flag),
        .parity_err     (parity_err)
      );
endmodule