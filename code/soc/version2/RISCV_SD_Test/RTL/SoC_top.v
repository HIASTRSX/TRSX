module SoC_top (

    clk,
    rst_n,
    //---------- uart ----------
    uart0_tx,
    uart0_rx,

    key1,
    key2,
    key3,
    
    sd_miso,
    sd_clk ,
    sd_cs  ,
    sd_mosi

);

input           clk;
input           rst_n;
output          uart0_tx;
input           uart0_rx;

input           key1;
input           key2;
input           key3;

//SD卡接�????               
input           sd_miso;  //SD卡SPI串行输入数据信号
output          sd_clk ;  //SD卡SPI时钟信号
output          sd_cs  ;  //SD卡SPI片�?�信�????
output          sd_mosi;  //SD卡SPI串行输出数据信号  

wire            clk_40M;

clk_wiz_0 instance_name
(
// Clock out ports
.clk_out1(clk_40M),     // output clk_out1
// Clock in ports
.clk_in1(clk));      // input clk_in1

SoC SoC_u (

    .clk                (clk_40M),
    .rst_n              (rst_n),
    //---------- uart ----------
    .uart0_tx           (uart0_tx),
    .uart0_rx           (uart0_rx),

    .key1               (key1),
    .key2               (key2),
    .key3               (key3),

    .sd_miso            (sd_miso),
    .sd_clk             (sd_clk ),
    .sd_cs              (sd_cs  ),
    .sd_mosi            (sd_mosi)
);


endmodule