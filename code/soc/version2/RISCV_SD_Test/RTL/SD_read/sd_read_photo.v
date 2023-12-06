//****************************************Copyright (c)***********************************//
//�?术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料�?
//版权�?有，盗版必究�?
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           sd_read_photo
// Last modified Date:  2018/3/18 8:41:06
// Last Version:        V1.0
// Descriptions:        SD卡读取图�?
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/18 8:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module sd_read_photo(
    input                clk           ,  //时钟信号
    input                rst_n         ,  //复位信号,低电平有�?
    
    input                rd_busy       ,  //SD卡读忙信�?
    output  reg          rd_start_en   ,  //�?始写SD卡数据信�?
    output  reg  [31:0]  rd_sec_addr   ,  //读数据扇区地�?

    input        [31:0]  dma_sec_addr  ,  //在dma_sd_read前赋有效值，在dma_sd_read有效前需要一直保�?
    input        [31:0]  dma_sec_counts,  //在dma_sd_read前赋有效值，在dma_sd_read有效前需要一直保�?
    input                dma_sd_read   ,  //DMA控制SD�?始读取数据信号，为上升沿信号 有效控制

    output               Read_finish      //SD读取�?次数据完成信�?
    );

//reg define
reg    [1:0]          rd_flow_cnt      ;   //读数据流程控制计数器
reg    [10:0]         rd_sec_cnt       ;   //读扇区次数计数器

reg                   rd_busy_d0       ;   //读忙信号打拍，用来采下降�?
reg                   rd_busy_d1       ;  

reg                   dma_sd_read_d0   ;   // dma_sec_addr为sys_clk时钟采样信号，现由clk_50m采样，需要做异步传输处理，打两拍d0、d1
reg                   dma_sd_read_d1   ;   // 同理，dma_sec_counts、dma_sd_read也需要做异步时钟处理
reg                   dma_sd_read_d2   ;

reg    [31:0]         dma_sec_addr_d0  ;
reg    [31:0]         dma_sec_addr_d1  ;

reg    [31:0]         dma_sec_counts_d0;
reg    [31:0]         dma_sec_counts_d1;

reg    [31:0]         dma_sec_addr_r   ;   //在dma_sd_read上升沿处赋�?�，保证硬件执行安全性，在读数过程中，dma_sec_addr、dma_sec_counts
reg    [31:0]         dma_sec_counts_r ;   //即使改变了，也不会改动这次读数的地址以及长度

//wire define
wire                  neg_rd_busy      ;   //SD卡读忙信号下降沿
wire                  pos_sd_read      ;   //SD卡读取信号有效上升沿，即在SD卡初始化完成后再�?始检测到读取上升�?
                                           //rst_n由SD卡初始化完成信号驱动
reg                   rd_done_r        ;   //�?次读取SD卡数据完成信�?
//*****************************************************
//**                    main code
//*****************************************************

assign  Read_finish = rd_done_r;
assign  neg_rd_busy = rd_busy_d1 & (~rd_busy_d0);
assign  pos_sd_read = dma_sd_read_d1 & (~dma_sd_read_d2);

//对rd_busy信号进行延时打拍,用于采rd_busy信号的下降沿
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        rd_busy_d0 <= 1'b0;
        rd_busy_d1 <= 1'b0;

        dma_sd_read_d0 <= 1'b0;
        dma_sd_read_d1 <= 1'b0;
        dma_sd_read_d2 <= 1'b0;

        dma_sec_addr_d0<= 32'd0;
        dma_sec_addr_d1<= 32'd0;

        dma_sec_counts_d0<= 32'd0;
        dma_sec_counts_d1<= 32'd0;
    end
    else begin
        rd_busy_d0 <= rd_busy;
        rd_busy_d1 <= rd_busy_d0;

        dma_sd_read_d0 <= dma_sd_read;
        dma_sd_read_d1 <= dma_sd_read_d0;
        dma_sd_read_d2 <= dma_sd_read_d1;

        dma_sec_addr_d0<= dma_sec_addr;
        dma_sec_addr_d1<= dma_sec_addr_d0;

        dma_sec_counts_d0<= dma_sec_counts;
        dma_sec_counts_d1<= dma_sec_counts_d0;
    end
end

//循环读取SD卡中的两张图片（读完之后延时1s再读下一个）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_flow_cnt <= 2'd0;
        rd_sec_cnt <= 11'd0;
        rd_start_en <= 1'b0;
        rd_sec_addr <= 32'd0;

        dma_sec_addr_r <= 32'd0;
        dma_sec_counts_r <= 32'd0;
        rd_done_r <= 1'b0;
    end
    else begin
        rd_start_en <= 1'b0;
        //rd_done_r  <= 1'b0;
        case(rd_flow_cnt)
            2'd0: begin
                if(pos_sd_read) begin
                    rd_flow_cnt <= rd_flow_cnt + 2'd1;

                    dma_sec_addr_r <= dma_sec_addr_d1;     //该两处信号保证代码执行安全�?�，�?旦有效赋值控制信号，读数过程不会改变
                    dma_sec_counts_r <= dma_sec_counts_d1; //pos_sd_read有效前，�?要dma_sec_addr、dma_sec_counts保持有效
                    rd_done_r  <= 1'b0;                 //每次�?始传送时将rd_done_r拉低，之后传输完成拉高，异步传输到sys_clk时钟域，�?测该信号的上升沿
                end
                else
                    rd_flow_cnt <= 2'd0;
            end
            2'd1 : begin
                //�?始读取SD卡数�?
                rd_flow_cnt <= rd_flow_cnt + 2'd1;
                rd_start_en <= 1'b1;

                rd_sec_addr <= dma_sec_addr_r;
            end
            2'd2 : begin
                //读忙信号的下降沿代表读完�?个扇�?,�?始读取下�?扇区地址数据
                if(neg_rd_busy) begin                          
                    rd_sec_cnt <= rd_sec_cnt + 11'd1;
                    rd_sec_addr <= rd_sec_addr + 32'd1;
                    //单张图片读完
                    if(rd_sec_cnt == dma_sec_counts_r - 11'b1) begin 
                        rd_sec_cnt <= 11'd0;
                        rd_flow_cnt <= rd_flow_cnt + 2'd1;
                    end    
                    else
                        rd_start_en <= 1'b1;                   
                end                    
            end
            2'd3 : begin
                rd_done_r  <= 1'b1; 
                rd_flow_cnt <= 2'd0;
            end    
            default : ;
        endcase    
    end
end

endmodule