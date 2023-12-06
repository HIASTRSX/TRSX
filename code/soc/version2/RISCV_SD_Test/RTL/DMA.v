module DMA (
    
    clk,
    rst_n,

    SD_StartAddr,
    sec_counts,
    SD_read,
    ahb_waddr,

    dma_haddr ,
    dma_hprot ,
    dma_htrans,
    dma_hwrite,
    dma_hsize ,
    dma_hburst,
    dma_hwdata,
    dma_hrdata,
    dma_hready,

    fifo_empty,
    fifo_rdata,
    fifo_rden,

    sec_addr_out,
    sec_counts_out,
    sd_read_out  
);

input           clk;
input           rst_n;

input  [31:0]   SD_StartAddr;           // from CPU, control SD read start addr       
input  [31:0]   sec_counts;             // and length
input           SD_read;                // control SD to read
input   [31:0]  ahb_waddr;              // 由CPU控制，DMA将数据写入哪块地址，通过csr寄存器改写，由SD_read前被赋有效值
                                        // SD_read上升沿，将ahb_waddr赋值给haddr
output  [31:0]  dma_haddr ;
output  [3:0]   dma_hprot ;
output  [1:0]   dma_htrans;
output          dma_hwrite;
output  [2:0]   dma_hsize ;
output  [2:0]   dma_hburst;
output  [31:0]  dma_hwdata;
input   [31:0]  dma_hrdata;    
input           dma_hready;

input           fifo_empty;
input   [31:0]  fifo_rdata;
output          fifo_rden;              // 控制fifo读出数据时序

output  [31:0]  sec_addr_out;
output  [31:0]  sec_counts_out;
output          sd_read_out;            // 控制开始读取SD数据

//----------------------------------test--------------------------------------
//reg     [31:0]   SD_StartAddr2;           // from CPU, control SD read start addr       
//reg     [31:0]   sec_counts2;             // and length
//reg              SD_read2;                // control SD to read
//reg     [31:0]   ahb_waddr2;  
//----------------------------------test--------------------------------------

parameter sector_size = 512;            // 扇区大小，一次连续读取SD卡512 bytes数据

reg             SD_read_d0;
reg             SD_read_d1;
wire            SD_read_pos;
reg     [31:0]  haddr;
wire    [31:0]  haddr_nxt;
reg     [31:0]  sec_addr_r;
reg     [31:0]  sec_counts_r;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        SD_read_d0 <= 1'b0;
        SD_read_d1 <= 1'b0;
    end
    else begin
        SD_read_d0 <= SD_read;
        //SD_read_d0 <= SD_read & sd_init_done;
        //SD_read_d0 <= SD_read2;
        SD_read_d1 <= SD_read_d0;        
    end
end
assign SD_read_pos    = SD_read_d0 & (~SD_read_d1);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        haddr <= 32'd0;
    else if(SD_read_pos)                // 将DMA写入的起始地址赋给haddr
        haddr <= ahb_waddr;
    else 
        haddr <= haddr_nxt;
end
assign haddr_nxt    = fifo_rden ? (haddr + 3'd4) : haddr;

//--------------------------control AHB write to ITCM/SRAM--------------------------------------
assign fifo_rden    = ~fifo_empty & dma_hready; // 当fifo非空时，且AHB ready时，进行读fifo操作，并通过AHB写入ITCM/SRAM  
assign dma_htrans   = fifo_rden ? 2'b10 : 2'b00;
assign dma_hwrite   = 1'b1;
assign dma_hprot    = 4'b0011;
assign dma_hburst   = 3'b000;
assign dma_hsize    = 3'b010;
assign dma_haddr    = haddr;
assign dma_hwdata   = fifo_rdata;

//-----------------------------------control SD_ctrl---------------------------------------------
//----------------------------------test--------------------------------------
//always @(posedge clk or negedge rst_n) begin
//    if(~rst_n) begin
//        SD_StartAddr2 <= 32'd0;
//        sec_counts2   <= 32'd0;
//        SD_read2      <= 1'b0;
//        ahb_waddr2    <= 32'd0;
//    end
//    else begin
//        SD_StartAddr2 <= 32'd0;
//        sec_counts2   <= 32'd2;  
//        ahb_waddr2    <= 32'h1000_0000;
//        if(sd_init_done) SD_read2 <= 1'b1;    
//    end
//end
//----------------------------------test--------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        sec_addr_r      <= 32'd0;
        sec_counts_r    <= 32'd0;
    end
    else begin
        sec_addr_r      <= SD_StartAddr;
        if(sec_counts == 1) sec_counts_r <= 32'd2;
        else sec_counts_r <= sec_counts;
    end
end
assign sec_addr_out = sec_addr_r;
assign sec_counts_out = sec_counts_r;
assign sd_read_out  = SD_read_d0;
    
endmodule