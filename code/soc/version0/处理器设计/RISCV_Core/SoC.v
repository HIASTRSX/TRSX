module SoC (

    clk,
    rst_n,
    //---------- uart ----------
    uart0_tx,
    uart0_rx,

    key1,
    key2,
    key3
);
    
input           clk;
input           rst_n;
output          uart0_tx;
input           uart0_rx;

input           key1;
input           key2;
input           key3;
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

//uart slave
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

core_top core_top_u(

    .clk                                (clk),
    .rst_n                              (rst_n),

    .i_haddr                            (HADDRI     ),
    .i_hprot                            (HPROTI     ),
    .i_htrans                           (HTRANSI    ),
    .i_hsize                            (HSIZEI     ),
    .i_hburst                           (HBURSTI    ),
    .i_hready                           (HREADYI    ),
    .i_hrdata                           (HRDATAI    ),
    .i_hrespi                           (HRESPI     ),
    .i_hsel                             (HSELI      ),

    .d_haddr                            (HADDRS     ),
    .d_hprot                            (HPROTS     ),
    .d_htrans                           (HTRANSS    ),
    .d_hwrite                           (HWRITES    ),
    .d_hsize                            (HSIZES     ),
    .d_hburst                           (HBURSTS    ),
    .d_hwdata                           (HWDATAS    ),
    .d_hrdata                           (HRDATAS    ),
    .d_hready                           (HREADYS    ),

    .key1                               (key1       ),
    .key2                               (key2       ),
    .key3                               (key3       ),
    .timer                              (timer      )
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

    // Scan test dummy signals; not connected until scan insertion
    .SCANOUTHCLK                        ()// Scan Chain Output

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
    .SRAMRDATA                          (ITCMRDATA),
    .SRAMADDR                           (ITCMADDR),
    .SRAMWEN                            (ITCMWRITE),
    .SRAMWDATA                          (ITCMWDATA),
    .SRAMCS                             (ITCMCS)
);
assign  HRESP_AHBL1P0[1]    =   1'b0;

cmsdk_fpga_sram #(
    .AW                                 (14)
)   ITCM    (
    .CLK                                (clk),
    .ADDR                               (ITCMADDR),
    .WDATA                              (ITCMWDATA),
    .WREN                               (ITCMWRITE),
    .CS                                 (ITCMCS),
    .RDATA                              (ITCMRDATA)

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
    .SRAMRDATA                          (DTCMRDATA),
    .SRAMADDR                           (DTCMADDR),
    .SRAMWEN                            (DTCMWRITE),
    .SRAMWDATA                          (DTCMWDATA),
    .SRAMCS                             (DTCMCS)
);
assign  HRESP_AHBL1P1[1]    =   1'b0;

cmsdk_fpga_sram #(
    .AW                                 (14)
)   DTCM    (
    .CLK                                (clk),
    .ADDR                               (DTCMADDR),
    .WDATA                              (DTCMWDATA),
    .WREN                               (DTCMWRITE),
    .CS                                 (DTCMCS),
    .RDATA                              (DTCMRDATA)

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
    .SRAMRDATA                          (pRDATA),
    .SRAMADDR                           (pADDR),
    .SRAMWEN                            (pWEN),
    .SRAMWDATA                          (pWDATA),
    .SRAMCS                             (pCS)
);
assign  HRESP_AHBL1P2[1]    =   1'b0;

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

  .timer     (timer)
);

endmodule