module SoC (

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

//SD卡接�???               
input           sd_miso;  //SD卡SPI串行输入数据信号
output          sd_clk ;  //SD卡SPI时钟信号
output          sd_cs  ;  //SD卡SPI片�?�信�???
output          sd_mosi;  //SD卡SPI串行输出数据信号  

wire            timer;
// I-Code
wire    [31:0]  HADDRI;
wire    [1:0]   HTRANSI;
wire    [2:0]   HSIZEI;
wire    [2:0]   HBURSTI;
wire    [3:0]   HPROTI;
wire    [31:0]  HRDATAI;
wire            HREADYI;
wire    [1:0]   HRESPI;
wire            HSELI;

// CPU System bus 
wire    [31:0]  HADDRS;
wire    [1:0]   HTRANSS;
wire            HWRITES;
wire    [2:0]   HSIZES;
wire    [31:0]  HWDATAS;
wire    [2:0]   HBURSTS;
wire    [3:0]   HPROTS;
wire            HREADYS;
wire    [31:0]  HRDATAS;
wire    [1:0]   HRESPS;
wire    [3:0]   HMASTERS;

assign  HMASTERS       =   4'b0001;

// DMA 
wire    [31:0]  dma_haddr ;
wire    [3:0]   dma_hprot ;
wire    [1:0]   dma_htrans;
wire            dma_hwrite;
wire    [2:0]   dma_hsize ;
wire    [2:0]   dma_hburst;
wire    [31:0]  dma_hwdata;
wire    [31:0]  dma_hrdata;    
wire            dma_hready;
wire    [1:0]   dma_hresp;

//ROM
wire    [31:0]  HADDR_AHBL1P0;
wire    [1:0]   HTRANS_AHBL1P0;
wire            HWRITE_AHBL1P0;
wire    [2:0]   HSIZE_AHBL1P0;
wire    [31:0]  HWDATA_AHBL1P0;
wire    [2:0]   HBURST_AHBL1P0;
wire    [3:0]   HPROT_AHBL1P0;
wire            HREADY_AHBL1P0;
wire    [31:0]  HRDATA_AHBL1P0;
wire    [1:0]   HRESP_AHBL1P0;
wire            HREADYOUT_AHBL1P0;
wire            HSEL_AHBL1P0;
wire    [1:0]   HMASTER_AHBL1P0;
wire            HMASTERLOCK_AHBL1P0;

//ITCM
wire    [31:0]  HADDR_AHBL1P1;
wire    [1:0]   HTRANS_AHBL1P1;
wire            HWRITE_AHBL1P1;
wire    [2:0]   HSIZE_AHBL1P1;
wire    [31:0]  HWDATA_AHBL1P1;
wire    [2:0]   HBURST_AHBL1P1;
wire    [3:0]   HPROT_AHBL1P1;
wire            HREADY_AHBL1P1;
wire    [31:0]  HRDATA_AHBL1P1;
wire    [1:0]   HRESP_AHBL1P1;
wire            HREADYOUT_AHBL1P1;
wire            HSEL_AHBL1P1;
wire    [1:0]   HMASTER_AHBL1P1;
wire            HMASTERLOCK_AHBL1P1;

//DTCM
wire    [31:0]  HADDR_AHBL1P2;
wire    [1:0]   HTRANS_AHBL1P2;
wire            HWRITE_AHBL1P2;
wire    [2:0]   HSIZE_AHBL1P2;
wire    [31:0]  HWDATA_AHBL1P2;
wire    [2:0]   HBURST_AHBL1P2;
wire    [3:0]   HPROT_AHBL1P2;
wire            HREADY_AHBL1P2;
wire    [31:0]  HRDATA_AHBL1P2;
wire    [1:0]   HRESP_AHBL1P2;
wire            HREADYOUT_AHBL1P2;
wire            HSEL_AHBL1P2;
wire    [1:0]   HMASTER_AHBL1P2;
wire            HMASTERLOCK_AHBL1P2;

//SRAM
wire    [31:0]  HADDR_AHBL1P3;
wire    [1:0]   HTRANS_AHBL1P3;
wire            HWRITE_AHBL1P3;
wire    [2:0]   HSIZE_AHBL1P3;
wire    [31:0]  HWDATA_AHBL1P3;
wire    [2:0]   HBURST_AHBL1P3;
wire    [3:0]   HPROT_AHBL1P3;
wire            HREADY_AHBL1P3;
wire    [31:0]  HRDATA_AHBL1P3;
wire    [1:0]   HRESP_AHBL1P3;
wire            HREADYOUT_AHBL1P3;
wire            HSEL_AHBL1P3;
wire    [1:0]   HMASTER_AHBL1P3;
wire            HMASTERLOCK_AHBL1P3;

//UART
wire    [31:0]  HADDR_AHBL1P4;
wire    [1:0]   HTRANS_AHBL1P4;
wire            HWRITE_AHBL1P4;
wire    [2:0]   HSIZE_AHBL1P4;
wire    [31:0]  HWDATA_AHBL1P4;
wire    [2:0]   HBURST_AHBL1P4;
wire    [3:0]   HPROT_AHBL1P4;
wire            HREADY_AHBL1P4;
wire    [31:0]  HRDATA_AHBL1P4;
wire    [1:0]   HRESP_AHBL1P4;
wire            HREADYOUT_AHBL1P4;
wire            HSEL_AHBL1P4;
wire    [1:0]   HMASTER_AHBL1P4;
wire            HMASTERLOCK_AHBL1P4;

//CPU control DMA
wire    [31:0]  SD_raddr;     
wire    [31:0]  SD_sec_counts;
wire    [31:0]  SD_read;      
wire    [31:0]  dma_waddr;    
wire            ReadSD_finish;

core_top core_top_u(

    .clk                                (clk),
    .rst_n                              (rst_n),

    .i_haddr                            (HADDRI         ),
    .i_hprot                            (HPROTI         ),
    .i_htrans                           (HTRANSI        ),
    .i_hsize                            (HSIZEI         ),
    .i_hburst                           (HBURSTI        ),
    .i_hready                           (HREADYI        ),
    .i_hrdata                           (HRDATAI        ),
    .i_hrespi                           (HRESPI         ),
    .i_hsel                             (HSELI          ),

    .d_haddr                            (HADDRS         ),
    .d_hprot                            (HPROTS         ),
    .d_htrans                           (HTRANSS        ),
    .d_hwrite                           (HWRITES        ),
    .d_hsize                            (HSIZES         ),
    .d_hburst                           (HBURSTS        ),
    .d_hwdata                           (HWDATAS        ),
    .d_hrdata                           (HRDATAS        ),
    .d_hready                           (HREADYS        ),

    .key1                               (key1           ),
    .key2                               (key2           ),
    .key3                               (key3           ),
    .timer                              (timer          ),
    .ReadSD_finish                      (ReadSD_finish  )

    //.SD_raddr                           (SD_raddr       ),     
    //.SD_sec_counts                      (SD_sec_counts  ),
    //.SD_read                            (SD_read        ),      
    //.dma_waddr                          (dma_waddr      )
);

L1AhbMtx L1AhbMtx_u (

    // Common AHB signals
    .HCLK                               (clk),
    .HRESETn                            (rst_n),

    // System address remapping control
    .REMAP                              (4'b0),

    // Input port SI0 (inputs from master 0)
    .HSELS0                             (HSELI),
    .HADDRS0                            (HADDRI),
    .HTRANSS0                           (HTRANSI),
    .HWRITES0                           (1'b0),
    .HSIZES0                            (HSIZEI),
    .HBURSTS0                           (HBURSTI),
    .HPROTS0                            (HPROTI),
    .HMASTERS0                          (4'b0),
    .HWDATAS0                           (32'b0),
    .HMASTLOCKS0                        (1'b0),
    .HREADYS0                           (HREADYI),
    .HAUSERS0                           (32'b0),
    .HWUSERS0                           (32'b0),

    // Input port SI1 (inputs from master 1)
    .HSELS1                             (1'b1),
    .HADDRS1                            (HADDRS),
    .HTRANSS1                           (HTRANSS),
    .HWRITES1                           (HWRITES),
    .HSIZES1                            (HSIZES),
    .HBURSTS1                           (HBURSTS),
    .HPROTS1                            (HPROTS),
    .HMASTERS1                          (HMASTERS),
    .HWDATAS1                           (HWDATAS),
    .HMASTLOCKS1                        (1'b0),
    .HREADYS1                           (HREADYS),
    .HAUSERS1                           (32'b0),
    .HWUSERS1                           (32'b0),

    // Input port SI2 (inputs from master 2)
    .HSELS2                             (1'b1),
    .HADDRS2                            (dma_haddr),
    .HTRANSS2                           (dma_htrans),
    .HWRITES2                           (dma_hwrite),
    .HSIZES2                            (dma_hsize),
    .HBURSTS2                           (dma_hburst),
    .HPROTS2                            (dma_hprot),
    .HMASTERS2                          (4'b0010),
    .HWDATAS2                           (dma_hwdata),
    .HMASTLOCKS2                        (1'b0),
    .HREADYS2                           (dma_hready),
    .HAUSERS2                           (32'b0),
    .HWUSERS2                           (32'b0),

    // Output port MI0 (inputs from slave 0)
    .HRDATAM0                           (HRDATA_AHBL1P0),
    .HREADYOUTM0                        (HREADYOUT_AHBL1P0),
    .HRESPM0                            (HRESP_AHBL1P0),
    .HRUSERM0                           (32'b0),

    // Output port MI1 (inputs from slave 1)
    .HRDATAM1                           (HRDATA_AHBL1P1),
    .HREADYOUTM1                        (HREADYOUT_AHBL1P1),
    .HRESPM1                            (HRESP_AHBL1P1),
    .HRUSERM1                           (32'b0),

    // Output port MI2 (inputs from slave 2)
   .HRDATAM2                            (HRDATA_AHBL1P2),
   .HREADYOUTM2                         (HREADYOUT_AHBL1P2),
   .HRESPM2                             (HRESP_AHBL1P2),
   .HRUSERM2                            (32'b0),

   // Output port MI3 (inputs from slave 3)
   .HRDATAM3                            (HRDATA_AHBL1P3),
   .HREADYOUTM3                         (HREADYOUT_AHBL1P3),
   .HRESPM3                             (HRESP_AHBL1P3),
   .HRUSERM3                            (32'b0),


   // Output port MI4 (inputs from slave 4)
   .HRDATAM4                            (HRDATA_AHBL1P4),
   .HREADYOUTM4                         (HREADYOUT_AHBL1P4),
   .HRESPM4                             (HRESP_AHBL1P4),
   .HRUSERM4                            (32'b0),

    // Scan test dummy signals; not connected until scan insertion
    .SCANENABLE                         (1'b0),   // Scan Test Mode Enable
    .SCANINHCLK                         (1'b0),   // Scan Chain Input


    // Output port MI0 (outputs to slave 0)
    .HSELM0                             (HSEL_AHBL1P0       ),
    .HADDRM0                            (HADDR_AHBL1P0      ),
    .HTRANSM0                           (HTRANS_AHBL1P0     ),
    .HWRITEM0                           (HWRITE_AHBL1P0     ),
    .HSIZEM0                            (HSIZE_AHBL1P0      ),
    .HBURSTM0                           (HBURST_AHBL1P0     ),
    .HPROTM0                            (HPROT_AHBL1P0      ),
    .HMASTERM0                          (HMASTER_AHBL1P0    ),
    .HWDATAM0                           (HWDATA_AHBL1P0     ),
    .HMASTLOCKM0                        (HMASTERLOCK_AHBL1P0),
    .HREADYMUXM0                        (HREADY_AHBL1P0     ),
    .HAUSERM0                           (),
    .HWUSERM0                           (),

    // Output port MI1 (outputs to slave 1)
    .HSELM1                             (HSEL_AHBL1P1       ),
    .HADDRM1                            (HADDR_AHBL1P1      ),
    .HTRANSM1                           (HTRANS_AHBL1P1     ),
    .HWRITEM1                           (HWRITE_AHBL1P1     ),
    .HSIZEM1                            (HSIZE_AHBL1P1      ),
    .HBURSTM1                           (HBURST_AHBL1P1     ),
    .HPROTM1                            (HPROT_AHBL1P1      ),
    .HMASTERM1                          (HMASTER_AHBL1P1    ),
    .HWDATAM1                           (HWDATA_AHBL1P1     ),
    .HMASTLOCKM1                        (HMASTERLOCK_AHBL1P1),
    .HREADYMUXM1                        (HREADY_AHBL1P1     ),
    .HAUSERM1                           (),
    .HWUSERM1                           (),

    // Output port MI2 (outputs to slave 2)
    .HSELM2                             (HSEL_AHBL1P2       ),
    .HADDRM2                            (HADDR_AHBL1P2      ),
    .HTRANSM2                           (HTRANS_AHBL1P2     ),
    .HWRITEM2                           (HWRITE_AHBL1P2     ),
    .HSIZEM2                            (HSIZE_AHBL1P2      ),
    .HBURSTM2                           (HBURST_AHBL1P2     ),
    .HPROTM2                            (HPROT_AHBL1P2      ),
    .HMASTERM2                          (HMASTER_AHBL1P2    ),
    .HWDATAM2                           (HWDATA_AHBL1P2     ),
    .HMASTLOCKM2                        (HMASTERLOCK_AHBL1P2),
    .HREADYMUXM2                        (HREADY_AHBL1P2     ),
    .HAUSERM2                           (),
    .HWUSERM2                           (),


    // Output port MI3 (outputs to slave 3)
    .HSELM3                             (HSEL_AHBL1P3       ),
    .HADDRM3                            (HADDR_AHBL1P3      ),
    .HTRANSM3                           (HTRANS_AHBL1P3     ),
    .HWRITEM3                           (HWRITE_AHBL1P3     ),
    .HSIZEM3                            (HSIZE_AHBL1P3      ),
    .HBURSTM3                           (HBURST_AHBL1P3     ),
    .HPROTM3                            (HPROT_AHBL1P3      ),
    .HMASTERM3                          (HMASTER_AHBL1P3    ),
    .HWDATAM3                           (HWDATA_AHBL1P3     ),
    .HMASTLOCKM3                        (HMASTERLOCK_AHBL1P3),
    .HREADYMUXM3                        (HREADY_AHBL1P3     ),
    .HAUSERM3                           (),
    .HWUSERM3                           (),


    // Output port MI4 (outputs to slave 4)
    .HSELM4                             (HSEL_AHBL1P4       ),
    .HADDRM4                            (HADDR_AHBL1P4      ),
    .HTRANSM4                           (HTRANS_AHBL1P4     ),
    .HWRITEM4                           (HWRITE_AHBL1P4     ),
    .HSIZEM4                            (HSIZE_AHBL1P4      ),
    .HBURSTM4                           (HBURST_AHBL1P4     ),
    .HPROTM4                            (HPROT_AHBL1P4      ),
    .HMASTERM4                          (HMASTER_AHBL1P4    ),
    .HWDATAM4                           (HWDATA_AHBL1P4     ),
    .HMASTLOCKM4                        (HMASTERLOCK_AHBL1P4),
    .HREADYMUXM4                        (HREADY_AHBL1P4     ),
    .HAUSERM4                           (),
    .HWUSERM4                           (),

    // Input port SI0 (outputs to master 0)
    .HRDATAS0                           (HRDATAI),
    .HREADYOUTS0                        (HREADYI),
    .HRESPS0                            (HRESPI),
    .HRUSERS0                           (),

    // Input port SI1 (outputs to master 1)
    .HRDATAS1                           (HRDATAS),
    .HREADYOUTS1                        (HREADYS),
    .HRESPS1                            (HRESPS),
    .HRUSERS1                           (),

    // Input port SI2 (outputs to master 2)
    .HRDATAS2                           (dma_hrdata),
    .HREADYOUTS2                        (dma_hready),
    .HRESPS2                            (dma_hresp),
    .HRUSERS2                           (),

    // Scan test dummy signals; not connected until scan insertion
    .SCANOUTHCLK                        ()// Scan Chain Output
);

//------------------------------------------------------------------------------
// AHB ROM
//------------------------------------------------------------------------------
wire    [11:0]  ROMADDR;
wire    [31:0]  ROMRDATA,ROMWDATA;
wire    [3:0]   ROMWRITE;
wire            ROMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (14)
)   AhbROM (
    .HCLK                               (clk),
    .HRESETn                            (rst_n),
    .HSEL                               (HSEL_AHBL1P0),
    .HREADY                             (HREADY_AHBL1P0),
    .HTRANS                             (HTRANS_AHBL1P0),
    .HSIZE                              (HSIZE_AHBL1P0),
    .HWRITE                             (HWRITE_AHBL1P0),
    .HADDR                              (HADDR_AHBL1P0),
    .HWDATA                             (HWDATA_AHBL1P0),
    .HREADYOUT                          (HREADYOUT_AHBL1P0),
    .HRESP                              (HRESP_AHBL1P0[0]),
    .HRDATA                             (HRDATA_AHBL1P0),
    .SRAMRDATA                          (ROMRDATA),
    .SRAMADDR                           (ROMADDR),
    .SRAMWEN                            (ROMWRITE),
    .SRAMWDATA                          (ROMWDATA),
    .SRAMCS                             (ROMCS)
);
assign  HRESP_AHBL1P0[1]    =   1'b0;

//cmsdk_fpga_sram #(
//    .AW                                 (12)
//)   ROM    (
//    .CLK                                (clk),
//    .ADDR                               (ROMADDR),
//    .WDATA                              (ROMWDATA),
//    .WREN                               (ROMWRITE),
//    .CS                                 (ROMCS),
//    .RDATA                              (ROMRDATA)
//);

blk_mem_gen_0 ROM (
  .clka(clk),    // input wire clka
  .ena(ROMCS),      // input wire ena
  .wea(ROMWRITE),      // input wire [3 : 0] wea
  .addra(ROMADDR),  // input wire [11 : 0] addra
  .dina(ROMWDATA),    // input wire [31 : 0] dina
  .douta(ROMRDATA)  // output wire [31 : 0] douta
);
//------------------------------------------------------------------------------
// AHB ITCM
//------------------------------------------------------------------------------
wire    [13:0]  ITCMADDR;
wire    [31:0]  ITCMRDATA,ITCMWDATA;
wire    [3:0]   ITCMWRITE;
wire            ITCMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16)
)   AhbItcm (
    .HCLK                               (clk),
    .HRESETn                            (rst_n),
    .HSEL                               (HSEL_AHBL1P1),
    .HREADY                             (HREADY_AHBL1P1),
    .HTRANS                             (HTRANS_AHBL1P1),
    .HSIZE                              (HSIZE_AHBL1P1),
    .HWRITE                             (HWRITE_AHBL1P1),
    .HADDR                              (HADDR_AHBL1P1),
    .HWDATA                             (HWDATA_AHBL1P1),
    .HREADYOUT                          (HREADYOUT_AHBL1P1),
    .HRESP                              (HRESP_AHBL1P1[0]),
    .HRDATA                             (HRDATA_AHBL1P1),
    .SRAMRDATA                          (ITCMRDATA),
    .SRAMADDR                           (ITCMADDR),
    .SRAMWEN                            (ITCMWRITE),
    .SRAMWDATA                          (ITCMWDATA),
    .SRAMCS                             (ITCMCS)
);
assign  HRESP_AHBL1P1[1]    =   1'b0;

//cmsdk_fpga_sram #(
//    .AW                                 (14)
//)   ITCM    (
//    .CLK                                (clk),
//    .ADDR                               (ITCMADDR),
//    .WDATA                              (ITCMWDATA),
//    .WREN                               (ITCMWRITE),
//    .CS                                 (ITCMCS),
//    .RDATA                              (ITCMRDATA)
//);
blk_mem_gen_1 ITCM (
  .clka(clk),    // input wire clka
  .ena(ITCMCS),      // input wire ena
  .wea(ITCMWRITE),      // input wire [3 : 0] wea
  .addra(ITCMADDR),  // input wire [13 : 0] addra
  .dina(ITCMWDATA),    // input wire [31 : 0] dina
  .douta(ITCMRDATA)  // output wire [31 : 0] douta
);
//------------------------------------------------------------------------------
// AHB DTCM
//------------------------------------------------------------------------------
wire    [13:0]  DTCMADDR;
wire    [31:0]  DTCMRDATA,DTCMWDATA;
wire    [3:0]   DTCMWRITE;
wire            DTCMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16)
)   AhbDtcm (
    .HCLK                               (clk),
    .HRESETn                            (rst_n),
    .HSEL                               (HSEL_AHBL1P2),
    .HREADY                             (HREADY_AHBL1P2),
    .HTRANS                             (HTRANS_AHBL1P2),
    .HSIZE                              (HSIZE_AHBL1P2),
    .HWRITE                             (HWRITE_AHBL1P2),
    .HADDR                              (HADDR_AHBL1P2),
    .HWDATA                             (HWDATA_AHBL1P2),
    .HREADYOUT                          (HREADYOUT_AHBL1P2),
    .HRESP                              (HRESP_AHBL1P2[0]),
    .HRDATA                             (HRDATA_AHBL1P2),
    .SRAMRDATA                          (DTCMRDATA),
    .SRAMADDR                           (DTCMADDR),
    .SRAMWEN                            (DTCMWRITE),
    .SRAMWDATA                          (DTCMWDATA),
    .SRAMCS                             (DTCMCS)
);
assign  HRESP_AHBL1P2[1]    =   1'b0;

//cmsdk_fpga_sram #(
//    .AW                                 (14)
//)   DTCM    (
//    .CLK                                (clk),
//    .ADDR                               (DTCMADDR),
//    .WDATA                              (DTCMWDATA),
//    .WREN                               (DTCMWRITE),
//    .CS                                 (DTCMCS),
//    .RDATA                              (DTCMRDATA)
//);
blk_mem_gen_2 DTCM (
  .clka(clk),    // input wire clka
  .ena(DTCMCS),      // input wire ena
  .wea(DTCMWRITE),      // input wire [3 : 0] wea
  .addra(DTCMADDR),  // input wire [13 : 0] addra
  .dina(DTCMWDATA),    // input wire [31 : 0] dina
  .douta(DTCMRDATA)  // output wire [31 : 0] douta
);

//------------------------------------------------------------------------------
// AHB SRAM
//------------------------------------------------------------------------------
wire    [25:0]  SRAMADDR;
wire    [31:0]  SRAMRDATA,SRAMWDATA;
wire    [3:0]   SRAMWRITE;
wire            SRAMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (28)
)   AhbSRAM (
    .HCLK                               (clk),
    .HRESETn                            (rst_n),
    .HSEL                               (HSEL_AHBL1P3),
    .HREADY                             (HREADY_AHBL1P3),
    .HTRANS                             (HTRANS_AHBL1P3),
    .HSIZE                              (HSIZE_AHBL1P3),
    .HWRITE                             (HWRITE_AHBL1P3),
    .HADDR                              (HADDR_AHBL1P3),
    .HWDATA                             (HWDATA_AHBL1P3),
    .HREADYOUT                          (HREADYOUT_AHBL1P3),
    .HRESP                              (HRESP_AHBL1P3[0]),
    .HRDATA                             (HRDATA_AHBL1P3),
    .SRAMRDATA                          (SRAMRDATA),
    .SRAMADDR                           (SRAMADDR),
    .SRAMWEN                            (SRAMWRITE),
    .SRAMWDATA                          (SRAMWDATA),
    .SRAMCS                             (SRAMCS)
);
assign  HRESP_AHBL1P3[1]    =   1'b0;

//cmsdk_fpga_sram #(
//    .AW                                 (26)
//)   SRAM    (
//    .CLK                                (clk),
//    .ADDR                               (SRAMADDR),
//    .WDATA                              (SRAMWDATA),
//    .WREN                               (SRAMWRITE),
//    .CS                                 (SRAMCS),
//    .RDATA                              (SRAMRDATA)
//);
blk_mem_gen_3 SRAM (
  .clka(clk),    // input wire clka
  .ena(SRAMCS),      // input wire ena
  .wea(SRAMWRITE),      // input wire [3 : 0] wea
  .addra(SRAMADDR),  // input wire [14 : 0] addra
  .dina(SRAMWDATA),    // input wire [31 : 0] dina
  .douta(SRAMRDATA)  // output wire [31 : 0] douta
);

//------------------------------------------------------------------------------
// AHB UART
//------------------------------------------------------------------------------
wire    [13:0]  pADDR;
wire    [31:0]  pRDATA,pWDATA;
wire    [3:0]   pWEN;
wire            pCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16)
)   Ahbpp (
    .HCLK                               (clk),
    .HRESETn                            (rst_n),
    .HSEL                               (HSEL_AHBL1P4),
    .HREADY                             (HREADY_AHBL1P4),
    .HTRANS                             (HTRANS_AHBL1P4),
    .HSIZE                              (HSIZE_AHBL1P4),
    .HWRITE                             (HWRITE_AHBL1P4),
    .HADDR                              (HADDR_AHBL1P4),
    .HWDATA                             (HWDATA_AHBL1P4),
    .HREADYOUT                          (HREADYOUT_AHBL1P4),
    .HRESP                              (HRESP_AHBL1P4[0]),
    .HRDATA                             (HRDATA_AHBL1P4),
    .SRAMRDATA                          (pRDATA),
    .SRAMADDR                           (pADDR),
    .SRAMWEN                            (pWEN),
    .SRAMWDATA                          (pWDATA),
    .SRAMCS                             (pCS)
);
assign  HRESP_AHBL1P4[1]    =   1'b0;

wire    p_write             =   |pWEN;
wire    p_read              =   pCS & (~p_write);

pp_peripheral_top pp_peripheral_top (
  .clk       (clk    ),
  .rst       (rst_n ),
  .addr      (pADDR[7:0]),
  .wr        (p_write),
  .rd        (p_read),
  .data_in   (pWDATA),
  .data_out  (pRDATA),
  .uart0_tx  (uart0_tx),
  .uart0_rx  (uart0_rx),
  .gpio_in   (),
  .gpio_out  (),
  .p_mode    (),

  .timer     (timer),

  .SDAddr    (SD_raddr),
  .SDCounts  (SD_sec_counts),
  .DestAddr  (dma_waddr),
  .DMAEN     (SD_read)    
);

//------------------------------------------------------------------------------
// DMA-afifo-SD
//------------------------------------------------------------------------------
wire            fifo_empty;
wire            fifo_rden;

wire            sd_rd_val_en;
wire    [31:0]  sd_rd_val_data;
wire    [31:0]  fifo_rdata;

wire    [31:0]  sec_addr;
wire    [31:0]  sec_counts;
wire            sd_read;

DMA DMA_u(
    
    .clk                                (clk),
    .rst_n                              (rst_n),

    .SD_StartAddr                       (SD_raddr),
    .sec_counts                         (SD_sec_counts),
    .SD_read                            (SD_read),
    .ahb_waddr                          (dma_waddr),

    .dma_haddr                          (dma_haddr),
    .dma_hprot                          (dma_hprot),
    .dma_htrans                         (dma_htrans),
    .dma_hwrite                         (dma_hwrite),
    .dma_hsize                          (dma_hsize),
    .dma_hburst                         (dma_hburst),
    .dma_hwdata                         (dma_hwdata),
    .dma_hrdata                         (dma_hrdata),
    .dma_hready                         (dma_hready),

    .fifo_empty                         (fifo_empty),
    .fifo_rdata                         (fifo_rdata),
    .fifo_rden                          (fifo_rden),

    .sec_addr_out                       (sec_addr),
    .sec_counts_out                     (sec_counts),
    .sd_read_out                        (sd_read) 
);

afifo #(                //默认数据宽度8，FIFO深度16
    .DW (32),       
    .AW (7)             // 512/4 = 128 = 2^7
) afifo_u (
    .clk_r                              (clk),
    .clk_w                              (clk_w),
    .rst_n                              (rst_n),
    .we                                 (sd_rd_val_en),
    .re                                 (fifo_rden),
    .din                                ({sd_rd_val_data[7:0],sd_rd_val_data[15:8],sd_rd_val_data[23:16],sd_rd_val_data[31:24]}),               // [DW-1:0]

    .dout                               (fifo_rdata),               // [DW-1:0]
    .empty                              (fifo_empty),
    .full                               ()      
);

top_sd_photo_vga top_sd_photo_vga_u (
    .sys_clk                            (clk),  //系统时钟
    .sys_rst_n                          (rst_n),  //系统复位，低电平有效
                          
    //SD卡接�???               
    .sd_miso                            (sd_miso ),  //SD卡SPI串行输入数据信号
    .sd_clk                             (sd_clk  ),  //SD卡SPI时钟信号
    .sd_cs                              (sd_cs   ),  //SD卡SPI片�?�信�???
    .sd_mosi                            (sd_mosi ),  //SD卡SPI串行输出数据信号  

    //from DMA, control to read data
    .dma_sec_addr                       (sec_addr),  //[31:0]
    .dma_sec_counts                     (sec_counts),  //[31:0]
    .dma_sd_read                        (sd_read),  // 控制开始读取SD数据

    .sd_rd_val_en                       (sd_rd_val_en),  // write to afifo, cs_wr
    .sd_rd_val_data                     (sd_rd_val_data),   // write to afifo, wdata [15:0]
    .clk_w                              (clk_w),             // afifo写数据时钟域

    .ReadSD_finish                      (ReadSD_finish)
);

reg clk_r;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) clk_r <= 1'b0;
    else clk_r <= ~clk_r;
    
end

ila_0 ila_0_u (
	.clk(clk), // input wire clk


	.probe0(clk_r), // input wire [0:0]  probe0  
	.probe1(fifo_rden), // input wire [0:0]  probe1 
	.probe2(fifo_rdata),  //32 bits
	.probe3(core_top_u.EX_top2_u.LSU_u.d_hready), // 1'
	.probe4(HADDRI), // input wire [31:0]  probe4 
	.probe5(HRDATAI), // input wire [31:0]  probe5 
	.probe6(core_top_u.EX_top2_u.LSU_u.d_htrans), // input wire [1:0]  probe6 
	.probe7(core_top_u.EX_top2_u.LSU_u.d_haddr), // input wire [31:0]  probe7 
	.probe8(core_top_u.EX_top2_u.LSU_u.d_hwrite), // input wire [0:0]  probe8 
	.probe9(core_top_u.EX_top2_u.LSU_u.d_hwdata), // input wire [31:0]  probe9
	.probe10(pp_peripheral_top.SDAddr_r[7:0]), // input wire [7:0]  probe10 
	.probe11(pp_peripheral_top.SDCounts_r[8:0]), // input wire [8:0]  probe11 
	.probe12(pp_peripheral_top.DestAddr_r[31:0]), // input wire [31:0]  probe12 
	.probe13(pp_peripheral_top.DMAEN_r), // input wire [0:0]  probe13
    .probe14(DMA_u.dma_hready),    // 1'
    .probe15(core_top_u.EX_top2_u.EXen_wb),
    .probe16(core_top_u.EX_top2_u.EXrd_wb),
    .probe17(core_top_u.EX_top2_u.EXdata_wb),
    .probe18(top_sd_photo_vga_u.u_sd_read_photo.rd_sec_cnt),           // 11bits
    .probe19(top_sd_photo_vga_u.u_sd_read_photo.dma_sec_counts_r),     // 11bits
    .probe20(top_sd_photo_vga_u.ReadSD_finish),

    .probe21(core_top_u.interrupt_ctrl_u.ReadSD_finish),
    .probe22(core_top_u.interrupt_ctrl_u.trap_entry_en),   
    .probe23(core_top_u.IF_u.trap_entry_pc),
    .probe24(core_top_u.CSRFile_u.mcause),
    .probe25(core_top_u.interrupt_ctrl_u.int_mstatus_mie),

    .probe26(core_top_u.EX_top2_u.LSU_u.Men_wb),     // 1'
    .probe27(core_top_u.EX_top2_u.LSU_u.Mrd_wb),    // 5'
    .probe28(core_top_u.EX_top2_u.LSU_u.Mdata_wb),   // 32'

    .probe29(core_top_u.Op1),     // 32'
    .probe30(core_top_u.Op2),    // 32'

    .probe31(DMA_u.dma_htrans),  // 2'
    .probe32(DMA_u.dma_haddr),   // 32'

    .probe33(sd_rd_val_en),
    .probe34(sd_rd_val_data),

    .probe35(DMA_u.sd_read_out),    // 1'
    .probe36(DMA_u.sec_addr_out),   // 32'
    .probe37(DMA_u.sec_counts_out)  // 32'  
);

endmodule