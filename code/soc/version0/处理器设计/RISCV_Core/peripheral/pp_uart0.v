module pp_uart0(
       clk,
       rst,
       soft_rst,
             
       tx_fifo_wrusedw,
       rx_fifo_rdusedw,
       tx_error,
       rx_error,
       tx_fifo_wrfull,
       tx_fifo_rdempty,
       rx_fifo_wrfull,
       rx_fifo_rdempty,
       tx_fifo_wrreq,
       tx_fifo_data,
       rx_fifo_rdreq,
       rx_fifo_q,
       uart_check_flag,
       uart_stop_flag,
       uart_data_flag,
       uart_baud_rate,
       uart_tx,
       uart_rx        
);
input  clk;
input  rst;
input  soft_rst;
output [8:0]tx_fifo_wrusedw;
output [8:0]rx_fifo_rdusedw;
output tx_error;
output rx_error;
output tx_fifo_wrfull;
output tx_fifo_rdempty;
output rx_fifo_wrfull;
output rx_fifo_rdempty;
input  tx_fifo_wrreq;
input  [7:0]tx_fifo_data;
input  rx_fifo_rdreq;
output [7:0]rx_fifo_q;

input  [1:0]uart_check_flag;
input  uart_stop_flag;
input  [1:0]uart_data_flag;
input  [13:0]uart_baud_rate;
output uart_tx;
input  uart_rx;

//------------ tx fifo ------------------------
wire tx_fifo_rdreq;

wire tx_fifo_rdempty;
wire tx_fifo_rdfull;
wire tx_fifo_wrempty;
wire tx_fifo_wrfull;

wire [8:0]tx_fifo_rdusedw;
wire [8:0]tx_fifo_wrusedw;
wire [7:0]tx_fifo_q;

//------------ rx fifo ------------------------
wire rx_fifo_wrreq;
wire [7:0]rx_fifo_data;

wire rx_fifo_rdempty;
wire rx_fifo_rdfull;
wire rx_fifo_wrempty;
wire rx_fifo_wrfull;

wire [8:0]rx_fifo_rdusedw;
wire [8:0]rx_fifo_wrusedw;
wire [7:0]rx_fifo_q;

reg tx_error;
reg rx_error;

//----------------- error flag --------------------------------
always @(posedge clk or negedge rst)
begin
  if(!rst)  
    tx_error <= 1'b0;
  else if(!soft_rst)
    tx_error <= 1'b0;
  else if(tx_fifo_wrfull && tx_fifo_wrreq)
    tx_error <= 1'b1;
end

always @(posedge clk or negedge rst)
begin
  if(!rst)  
    rx_error <= 1'b0;
  else if(!soft_rst)
    rx_error <= 1'b0;
  else if((rx_fifo_rdempty && rx_fifo_rdreq) || (rx_fifo_wrfull && rx_fifo_wrreq))
    rx_error <= 1'b1;
end

//-----------------------------------------------------------------
// FIFO 0 BIST 
//-----------------------------------------------------------------
//-----------------------------------------------------------------


//----------------- tx fifo ------------------------------------
fifo_256 tx_fifo_obj(
       .rdclk      (clk),
       .wrclk      (clk) ,
       .rd_rst     (rst),           //asynchronous; low valid
       .wr_rst     (rst) ,
       .wr_soft_rst(soft_rst),
       .rd_soft_rst(soft_rst),

       .wrreq      (tx_fifo_wrreq),
       .data       (tx_fifo_data),
       .wrempty    (tx_fifo_wrempty),
       .wrfull     (tx_fifo_wrfull),
       .wrusedw    (tx_fifo_wrusedw),

       .rdreq      (tx_fifo_rdreq),
       .q          (tx_fifo_q),
       .rdempty    (tx_fifo_rdempty),
       .rdfull     (tx_fifo_rdfull),
       .rdusedw    (tx_fifo_rdusedw)
);
//--------------------rx fifo ---------------------------------------
fifo_256 rx_fifo_obj(
       .rdclk      (clk),
       .wrclk      (clk),
       .rd_rst     (rst),           //asynchronous; low valid
       .wr_rst     (rst),
       .wr_soft_rst(soft_rst),
       .rd_soft_rst(soft_rst),

       .wrreq      (rx_fifo_wrreq),
       .data       (rx_fifo_data),
       .wrempty    (rx_fifo_wrempty),
       .wrfull     (rx_fifo_wrfull),
       .wrusedw    (rx_fifo_wrusedw),

       .rdreq      (rx_fifo_rdreq),        
       .q          (rx_fifo_q),
       .rdempty    (rx_fifo_rdempty),
       .rdfull     (rx_fifo_rdfull),
       .rdusedw    (rx_fifo_rdusedw)
);


//--------------------- uart module -------------------------------------

wire [1:0]uart_parity_error;

pp_uart_top pp_uart_top(
        .clk(clk),
        .rst(rst),
        .soft_rst(soft_rst),
        .uart_tx_fifo_empty(tx_fifo_rdempty),  //tx_fifo ---> uart
        .uart_rx_fifo_full(rx_fifo_wrfull),      //rx_fifo ---> uart
        .uart_tx_fifo_data(tx_fifo_q),         //tx_fifo ---> uart
        .uart_rx_fifo_data(rx_fifo_data),      //uart ---> rx_fifo
        .uart_rx_fifo_wreq(rx_fifo_wrreq),     //uart ---> rx_fifo
        .uart_tx_fifo_rreq(tx_fifo_rdreq),     //uart ---> tx_fifo
  
        .uart_rx(uart_rx),                     //input
        .uart_tx(uart_tx),                     //output
  // Configuration
        .uart_baud(uart_baud_rate),            //aurt_baud = sys_clk/uart_clk
        .data_flag(uart_data_flag),            //00:5bits,01:6bits,10:7bits,11:8bits
        .stop_flag(uart_stop_flag),            //0 :1bit,1:2bits
        .check_flag(uart_check_flag),          //00:without,01:odd,10:even,11:reserve
        .parity_err(uart_parity_error)         //00:no error ,01:odd check error, 10: even check error,11:reserve
);



       
endmodule