//
// Company: 
// Engineer: guoliang CLL
// 
// Create Date: 2020/03/24 20:51:06
// Design Name: 
// Module Name: afifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//
 
module afifo
#(parameter DW = 8,AW = 4)//默认数据宽度8，FIFO深度16
(
    input clk_r,
    input clk_w,
    input rst_n,
    input we,
    input re,
    input [DW-1:0]din,
    output reg [DW-1:0]dout,
    output empty,
    output full
    );
// internal signal
parameter Depth = 1 << AW;//depth of FIFO 
reg [DW-1:0]ram[0:Depth-1];
reg [AW:0]wp;  //point
reg [AW:0]rp;
wire [AW:0]wp_g;//Gray point
wire [AW:0]rp_g;
reg [AW:0]wp_m;//mid_point for syn
reg [AW:0]rp_m;
reg [AW:0]wp_s;//point after syn
reg [AW:0]rp_s;

reg [AW:0]wp_gr;//写指针格雷码组合逻辑时序输出
reg [AW:0]rp_gr;//读指针格雷码组合逻辑时序输出
// FIFO declaration
// 二进制指针转换为格雷指针
assign wp_g = (wp>>1) ^ wp;
assign rp_g = (rp>>1) ^ rp;
// 空满检测,使用同步后的格雷指针?
assign empty = (wp_s == rp_g)?1'b1:1'b0;// 空检测,使用同步后的写格雷指针
assign full = ( {~wp_g[AW:AW-1] , wp_g[AW-2:0]} == {rp_s[AW:AW-1] , rp_s[AW-2:0]} )?1'b1:1'b0;  // 满检测,使用同步后的读格雷指针
// 读指针
always@(posedge clk_r or negedge rst_n)
begin
    if(!rst_n)
        rp <= {AW{1'b0}};
    else if(!empty & re)
        rp <= rp+1'b1;
    else
        rp <= rp;
end
//写指针
always@(posedge clk_w or negedge rst_n)
begin
    if(!rst_n)
        wp <= {AW{1'b0}};
    else if(!full & we)
        wp <= wp+1'b1;
    else
        wp <= wp;
end
// 读操作
always@(posedge clk_r or negedge rst_n)
begin
    if(!rst_n)
        dout <= {DW{1'bz}};
    else if(!empty & re)
        dout <= ram[rp[AW-1:0]];
    else
        dout <= dout;
end
//写操作
always@(posedge clk_w)
begin
    if(!full & we)
        ram[wp[AW-1:0]] <= din;
    else
        ram[wp[AW-1:0]] <= ram[wp[AW-1:0]];
end
// 读时钟域，写地址同步
// 将写地址格雷码同步到读时钟域之前，需要将wp_g在写时钟域时序输出，wp_g为组合逻辑输出
// wp_g直接由读时钟采样的话，格雷码转换没有意义
always @(posedge clk_w or negedge rst_n) begin
    if(!rst_n)
        wp_gr <= 1'b0;
    else
        wp_gr <= wp_g;
end
always@(posedge clk_r or negedge rst_n)
begin
    if(!rst_n)
        begin
            wp_m <= {AW{1'b0}};
            wp_s <= {AW{1'b0}};       
        end
    else
        begin
            wp_m <= wp_gr;
            wp_s <= wp_m;    
        end       
end
// 写时钟域，读地址同步
always @(posedge clk_r or negedge rst_n) begin
    if(!rst_n)
        rp_gr <= 1'b0;
    else
        rp_gr <= rp_g;
end
always@(posedge clk_w or negedge rst_n)
begin
    if(!rst_n)
        begin
            rp_m <= {AW{1'b0}};
            rp_s <= {AW{1'b0}};       
        end
    else
        begin
            rp_m <= rp_gr;
            rp_s <= rp_m;    
        end       
end
endmodule