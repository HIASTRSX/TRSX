
module pp_uart_transceiver  (  
        clk,
        rst,
        soft_rst,
        uart_baud,
        // Transmitter
        uart_XMIT_dataH,
        xmitH,
        xmit_dataH,
        xmit_doneH,

        // Receiver
        uart_REC_dataH,
        rec_dataH,
        rec_readyH,
        data_flag,
        stop_flag,
        check_flag,
        parity_err
      );
 
input  clk;
input  rst;
input  soft_rst;
input[13:0]uart_baud;
// Trasmitter
output uart_XMIT_dataH;
input  xmitH;
input  [7:0]  xmit_dataH;
output xmit_doneH;

// Receiver
input  uart_REC_dataH;
output [7:0]  rec_dataH;
output rec_readyH;

// Configuration
input  [1:0]data_flag;    //00:5bits,01:6bits,10:7bits,11:8bits
input  stop_flag;         //0 :1bit,1:2bts
input  [1:0]check_flag;  //00:without,01:odd,10:even,11:reserve
output [1:0]parity_err;

wire  uart_clk;
wire  [7:0]rec_dataH;
wire  rec_readyH;



// Instantiate the Transmitter
pp_uart_transmitter  pp_uart_transmitter(  
        .clk(clk),
        .rst(rst),
        .soft_rst(soft_rst),
        .uart_clk(uart_clk),
        .uart_xmitH(uart_XMIT_dataH),
        .xmitH(xmitH),
        .xmit_dataH(xmit_dataH),
        .xmit_doneH(xmit_doneH),
        .data_flag(data_flag),
        .stop_flag (stop_flag),
        .check_flag(check_flag)
      );


// Instantiate the Receiver


pp_uart_receiver pp_uart_receiver(// system connections
        .rst(rst),
        .clk(clk),
        .soft_rst(soft_rst),
        .uart_clk(uart_clk),      
        // uart
        .uart_dataH(uart_REC_dataH),

        .rec_dataH(rec_dataH),
        .rec_readyH(rec_readyH),
        
        .data_flag(data_flag),
        .check_flag(check_flag),
        .parity_err(parity_err)
        );


// Instantiate the Baud Rate Generator

pp_uart_baud pp_uart_baud(
      .clk(clk),
      .rst(rst),  
      .soft_rst(soft_rst),
      .baud_div(uart_baud),  
      .baud_clk(uart_clk)
    );



endmodule
