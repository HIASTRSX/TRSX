`include "pvt_int_defs.v"
module pp_peripheral_top(
       clk,
       rst,
       addr,
       wr,
       rd,
       data_in,
       data_out,
       //---------- uart ----------
       uart0_tx,
       uart0_rx,
       //-------- gpio -------------
       gpio_in,
       gpio_out, 
       p_mode,
       //-------- timer ------------
       timer
);
input  clk;
input  rst;
input  [7:0]addr;
input  wr;
input  rd;
input  [31:0]data_in;
output [31:0]data_out;

output uart0_tx;
input  uart0_rx;
input  [23:0]gpio_in; 
output [23:0]gpio_out; 
output [23:0]p_mode; 

output timer;


reg  [31:0]data_out;

wire uart0_tx;


//-----------------------------------------------------------------
// clock & reset bypass for test mode
//-----------------------------------------------------------------
//-----------------------------------------------------------------


//----------------CLK GATE----------------------------
reg  uart0_clk_ena ;
wire uart0_gclk    ;
wire uart0_clk_gate;


//always @(posedge clk or negedge rst)
//begin
//  if(!rst)
//    begin
//      uart0_clk_ena         <= 1'b1;
//    end
//  else 
//    begin
//      if(wr && (addr == `UART0_CLK_CTRL))    uart0_clk_ena <= data_in[0];
//    end
//end


//clk_gate_wrapper i_uart0_clk_gate(
//    .i_clk   (clk           ),
//    .i_clk_en(uart0_clk_ena ),
//    .o_gclk  (uart0_clk_gate)
//);



//------------------ GPIO -------------------------------------------
// p_mode[0]   p0_mode   0:input 1:output
// p_mode[1]   p1_mode   0:input 1:output
// p_mode[2]   p2_mode   0:input 1:output
// p_mode[3]   p3_mode   0:input 1:output
// p_mode[4]   p4_mode   0:input 1:output  uart_tx
// p_mode[5]   p5_mode   0:input 1:output  uart_rx
// p_mode[6]   p6_mode   0:input 1:output  spi_clk
// p_mode[7]   p7_mode   0:input 1:output  spi_cs
// p_mode[8]   p8_mode   0:input 1:output  spi_mosi
// p_mode[9]   p9_mode   0:input 1:output  spi_miso
// p_mode[10]  p10_mode  0:input 1:output  scl
// p_mode[11]  p11_mode  0:input 1:output  sda
reg [23:0]p_mode; 
reg [23:0]gpio_state;
reg [23:0]gpio_out;

always @(posedge clk or negedge rst)
begin
  if(!rst)
     p_mode <= 24'h0; 
  else if((addr == `GPIO_CTRL) && wr)
     p_mode <= data_in[23:0];
end

reg [23:0]gpio_in_reg;

always @(posedge clk or negedge rst)
begin
  if(!rst)  
     gpio_in_reg <= 24'b0;
  else      
     gpio_in_reg <= gpio_in;
end

always @(posedge clk or negedge rst)
begin
  if(!rst)  
     gpio_state <= 24'b0;
  else      
     gpio_state <= gpio_in_reg;
end

always @(posedge clk or negedge rst)
begin
  if(!rst)
    gpio_out <= 24'h0;
  else if((addr == `GPIO_OUT) && wr)
    gpio_out <= data_in[23:0];
end


//------------------ UART0 ------------------------------------------
wire tx_fifo0_wrreq;
wire [7:0]tx_fifo0_data;
wire rx_fifo0_rdreq;
wire [7:0]rx_fifo0_q;
wire [8:0]tx_fifo0_wrusedw;
wire [8:0]rx_fifo0_rdusedw;
wire tx_fifo0_overflow;
wire rx_fifo0_overflow;
wire tx_fifo0_wrfull;
wire tx_fifo0_rdempty;
wire rx_fifo0_wrfull;
wire rx_fifo0_rdempty;

reg [1:0]uart0_check_flag;
reg uart0_stop_flag;
reg [1:0]uart0_data_flag;
reg [13:0]uart0_baud_rate;
reg fifo0_rst;

always @(posedge clk or negedge rst)
begin
  if(!rst)
    begin
      uart0_check_flag <= 2'b0;
      uart0_stop_flag  <= 1'b0;
      uart0_data_flag  <= 2'b0;
      uart0_baud_rate  <= 14'd0;
      fifo0_rst        <= 1'b1;
    end 
  else 
    begin
      if(wr && (addr == `UART0_CTRL))  uart0_check_flag <= data_in[4:3];  
      if(wr && (addr == `UART0_CTRL))  uart0_stop_flag  <= data_in[2];  
      if(wr && (addr == `UART0_CTRL))  uart0_data_flag  <= data_in[1:0];
      if(wr && (addr == `UART0_BAUD))  uart0_baud_rate  <= data_in[13:0];
      if(wr && (addr == `RST_FIFO0))         fifo0_rst  <= data_in[0];
    end
end

assign tx_fifo0_wrreq = (wr && (addr == `TX_FIFO0))?1'b1:1'b0;
assign tx_fifo0_data  = data_in[7:0];
assign rx_fifo0_rdreq = (rd && (addr == `RX_FIFO0))?1'b1:1'b0;

pp_uart0 pp_uart0(
        .clk            (clk),
        .rst            (rst),
        .soft_rst       (fifo0_rst),

        //-------------tx fifo --------------
        .tx_fifo_wrreq  (tx_fifo0_wrreq),
        .tx_fifo_data   (tx_fifo0_data),
        .tx_fifo_wrfull (tx_fifo0_wrfull),
        .tx_fifo_rdempty(tx_fifo0_rdempty),
        .tx_fifo_wrusedw(tx_fifo0_wrusedw),
        .tx_error       (tx_fifo0_overflow),
        //-------------rx fifo --------------
        .rx_fifo_rdreq  (rx_fifo0_rdreq),
        .rx_fifo_q      (rx_fifo0_q),
        .rx_fifo_wrfull (rx_fifo0_wrfull),
        .rx_fifo_rdempty(rx_fifo0_rdempty),
        .rx_fifo_rdusedw(rx_fifo0_rdusedw),
        .rx_error       (rx_fifo0_overflow),
        //------------ uart0 param.-----------
        .uart_check_flag(uart0_check_flag),
        .uart_stop_flag (uart0_stop_flag),
        .uart_data_flag (uart0_data_flag),
        .uart_baud_rate (uart0_baud_rate),
        //------------ uart0 interface -------
        .uart_tx        (uart0_tx),
        .uart_rx        (uart0_rx)     
       );


//------------------------- output -----------------------------
reg [7:0]addr_reg;

always @(posedge clk or negedge rst)
begin
  if(!rst)
     addr_reg <= 8'h0; 
  else 
     addr_reg <= addr;
end

always @( * )
begin
       if(addr_reg == `UART0_CTRL)   data_out = {27'h0,uart0_check_flag,uart0_stop_flag,uart0_data_flag};
  else if(addr_reg == `UART0_BAUD)   data_out = {18'h0,uart0_baud_rate};
  else if(addr_reg == `GPIO_CTRL)    data_out = {8'h0,p_mode};
  else if(addr_reg == `RX_FIFO0)     data_out = {24'h0,rx_fifo0_q};
  else if(addr_reg == `FIFO0_SZE)    data_out = {8'h0,tx_fifo0_wrusedw[7:0],8'h0,rx_fifo0_rdusedw[7:0]};
  else if(addr_reg == `FIFO0_STATUS) data_out = {24'h0,tx_fifo0_overflow,rx_fifo0_overflow,tx_fifo0_wrfull,tx_fifo0_rdempty,rx_fifo0_wrfull,rx_fifo0_rdempty};
  else if(addr_reg == `GPIO_STATUS)  data_out = {8'h0,gpio_state};
  else if(addr_reg == `GPIO_OUT)     data_out = {8'h0,gpio_out};
  else                               data_out = 32'h0;
end

//----------------------- timer interrupt --------------------------
reg [31:0] mtimecmp;
reg [31:0] mtime;
reg        mcountstar;
reg        time_interrupt;
always @(posedge clk or negedge rst)
begin
  if(!rst) begin
     mtimecmp   <= 32'hffffffff; 
     mcountstar <= 1'b0;
  end
  else begin
    if(wr && (addr == `MTIMECMP))    mtimecmp     <= data_in;  
    if(wr && (addr == `MCOUNTSTAR))  mcountstar   <= data_in[0];
  end
end

always @(posedge clk or negedge rst) begin
  if(!rst) begin
    mtime       <= 32'h0;
  end
  else begin
    if(mcountstar) begin
      if(&mtime)                    //mtime == 32'hffffffff,停止计数
        mtime     <= mtime;
      else mtime  <= mtime + 1'b1;
    end
    else begin
      mtime     <= 32'h0;
    end
  end
end

always @(posedge clk or negedge rst) begin
  if(!rst) begin
    time_interrupt    <= 1'b0;
  end
  else begin
    if(mtime >= mtimecmp) 
      time_interrupt  <= 1'b1;
    else
      time_interrupt  <= 1'b0;            //在开启下次时钟中断前需要先关闭 mcountstar
  end
end
assign timer          = time_interrupt;

endmodule
