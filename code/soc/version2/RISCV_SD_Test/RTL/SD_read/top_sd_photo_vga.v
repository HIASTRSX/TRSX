//****************************************Copyright (c)***********************************//
//�???术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料�???
//版权�???有，盗版必究�???
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           top_sd_photo_vga
// Last modified Date:  2018/3/18 8:41:06
// Last Version:        V1.0
// Descriptions:        SD VGA图片显示实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/18 8:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_sd_photo_vga #(parameter DW = 32) //默认单个数据位宽32bits
(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
                          
    //SD卡接�???               
    input                 sd_miso     ,  //SD卡SPI串行输入数据信号
    output                sd_clk      ,  //SD卡SPI时钟信号
    output                sd_cs       ,  //SD卡SPI片�?�信�???
    output                sd_mosi     ,  //SD卡SPI串行输出数据信号  

    //from DMA, control to read data
    input     [31:0]      dma_sec_addr,   // 该三个信号在sys_clk时钟域下，需要做异步时钟域传输
    input     [31:0]      dma_sec_counts,
    input                 dma_sd_read,    // 控制开始读取SD数据

    output                sd_rd_val_en,   // write to afifo, cs_wr
    output    [DW-1:0]    sd_rd_val_data, // write to afifo, wdata

    output                clk_w,
    output                ReadSD_finish   //SD卡读取CPU配置的数据量完成信号, 单周期信号，检测Read_finish上升沿
    );

//wire define
wire                  clk_50m         ;
wire                  clk_50m_180deg  ;
wire                  rst_n           ;
//wire                  locked          ;
wire                  sys_init_done   ;  //系统初始化完�???
                                      
wire                  sd_rd_start_en  ;  //�???始写SD卡数据信�???
wire          [31:0]  sd_rd_sec_addr  ;  //读数据扇区地�???    
wire                  sd_rd_busy      ;  //读忙信号
wire                  sd_init_done    ;  //SD卡初始化完成信号

//wire          [15:0]  rd_ram_data     ;  //ram中读取数�??
//wire          [17:0]  addrB           ;  //ram读取地址
wire                  Read_finish;
reg                   Read_finish_r0;
reg                   Read_finish_r1;
reg                   Read_finish_r2;
   

//*****************************************************
//**                    main code
//*****************************************************
//assign  rst_n = sys_rst_n & locked;
assign  rst_n = sys_rst_n;
assign  sys_init_done = sd_init_done;  //SD卡初始化完成

assign  clk_w = clk_50m;
//锁相�???
reg                   clk_50m_r       ;
assign  clk_50m = clk_50m_r;
assign  clk_50m_180deg = ~clk_50m;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(~sys_rst_n)
        clk_50m_r <= 1'b0;
    else
        clk_50m_r <= ~clk_50m_r;
end

/*
clk_wiz_0 instance_name
(
    // Clock out ports
    .clk_50m(clk_50m),     // output clk_50m
    .clk_50m_180deg(clk_50m_180deg),     // output clk_50m_180deg
    // Status and control signals
    .reset(1'b0), // input reset
    .locked(locked),       // output locked
    // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1  */



//读取SD卡图�???
sd_read_photo u_sd_read_photo(
    .clk             (clk_50m),
    //系统初始化完成之�???,再开始从SD卡中读取数据
    .rst_n           (rst_n & sys_init_done), 
    .rd_busy         (sd_rd_busy),
    .rd_start_en     (sd_rd_start_en),
    .rd_sec_addr     (sd_rd_sec_addr),

    .dma_sec_addr    (dma_sec_addr  ),
    .dma_sec_counts  (dma_sec_counts  ),
    .dma_sd_read     (dma_sd_read  ),

    .Read_finish     (Read_finish)      // 在clk_50m在输出，需要做异步时钟数据传输到sys_clk下
    );     

//SD卡顶层控制模�???
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref           (clk_50m),
    .clk_ref_180deg    (clk_50m_180deg),
    .rst_n             (rst_n),
    //SD卡接�???
    .sd_miso           (sd_miso),
    .sd_clk            (sd_clk),
    .sd_cs             (sd_cs),
    .sd_mosi           (sd_mosi),
    //用户写SD卡接�???
    .wr_start_en       (1'b0),               //不需要写入数�???,写入接口赋�?�为0
    .wr_sec_addr       (32'b0),
    .wr_data           (16'b0),
    .wr_busy           (),
    .wr_req            (),
    //用户读SD卡接�???
    .rd_start_en       (sd_rd_start_en),
    .rd_sec_addr       (sd_rd_sec_addr),
    .rd_busy           (sd_rd_busy),
    .rd_val_en         (sd_rd_val_en),
    .rd_val_data       (sd_rd_val_data),    
    
    .sd_init_done      (sd_init_done)
    );  

// Read_finish异步时钟采样，并检测同步时钟域后的信号Read_finish_r1上升沿

assign ReadSD_finish = Read_finish_r1 & (~Read_finish_r2);
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(~sys_rst_n) begin
        Read_finish_r0 <= 1'b0;
        Read_finish_r1 <= 1'b0;
        Read_finish_r2 <= 1'b0;
    end
    else begin
        Read_finish_r0 <= Read_finish;
        Read_finish_r1 <= Read_finish_r0;    
        Read_finish_r2 <= Read_finish_r1;    
    end
end
/*
sd_to_ram sd_to_ram_u (
   .clk_ref             (clk_50m),
   .rst_n               (rst_n),
   .rd_val_en           (sd_rd_val_en),
   .rd_val_data         (sd_rd_val_data),
   .rd_ram_data         (rd_ram_data),
   .addrB               (addrB)
);

reg     clk_50m_r;
always @(posedge clk_50m or negedge rst_n) begin
    if (~rst_n) clk_50m_r <= 1'b0;
    else        clk_50m_r <= ~clk_50m_r;
end

ila_0 your_instance_name (
	.clk(clk_50m),              // input wire clk

	.probe0(clk_50m_r),         // input wire [0:0]  probe0  
	.probe1(sd_rd_val_data),    // input wire [15:0]  probe1 
	.probe2(rd_ram_data),       // input wire [15:0]  probe2 
	.probe3(addrB)              // input wire [17:0]  probe3
);  */

endmodule