//***************************************************************************************/
//Title  :	asyn_fifo.v
//Author :	lijian
//Description :	This module realizes fifo with asynchronous read/write function
//Created:	Thu Dec 27 15:47:29 2012
//version:	1.0
//Company:	IMECAS GPS SoC
//Copyright(c) 2012, IMECAS, all right reserved
//***************************************************************************************/
//`timescale 1ns/1ns

module fifo_256(
       wrclk       ,
       wr_rst      ,
       wr_soft_rst ,
       rdclk       ,
       rd_rst      ,
       rd_soft_rst ,

       wrreq       ,
       data        ,
       wrempty     ,
       wrfull      ,
       wrusedw     ,
       
       rdreq       ,        
       q           ,
       rdempty     ,
       rdfull      ,        
       rdusedw
);

//***************************************************************************************/
//			input/output IO declare
//***************************************************************************************/
    parameter DEPTH = 256 ;
    parameter D_W = 8 ;
    parameter A_W = 8 ;

    input               rdclk               ;
    input               wrclk               ;
    input               wr_rst              ;
    input               rd_rst              ;
    input               wr_soft_rst         ;
    input               rd_soft_rst         ;
    input               rdreq               ;  //rdclk domain
    input               wrreq               ;  //wrclk domain
    input   [D_W - 1:0] data                ;  //wrclk domain
    output              rdfull              ;  //rdclk domain
    output              rdempty             ;  //rdclk domain
    output              wrfull              ;  //wrclk domain
    output              wrempty             ;  //wrclk domain
    output  [A_W    :0] rdusedw             ;  //rdclk domain
    output  [A_W    :0] wrusedw             ;  //wrclk domain
    output  [D_W - 1:0] q                   ;  //rdclk domain

    wire                test_done           ;
    wire                test_failed         ; 
    wire                rdempty             ;
    wire                rdfull              ;
    wire                wrfull              ;
    wire                wrempty             ;
    reg     [A_W    :0] rdusedw             ;
    reg     [A_W    :0] wrusedw             ;
    wire    [D_W - 1:0] q                   ;
//***************************************************************************************/
//			code begin here
//***************************************************************************************/
    wire                wren                ;  //dp_ram wren signal
    wire    [A_W - 1:0] wraddr              ;  //ram wraddr
    reg     [A_W : 0]   wr_bin              ;
    wire    [A_W : 0]   wr_bin_next         ;

    reg     [A_W : 0]   wr_ptr              ;  //for rd sync
    reg     [A_W : 0]   wr_ptr_reg1         ;
    reg     [A_W : 0]   wr_ptr_reg2         ;



    wire                rden                ;  //dp_ram rden signal
    wire    [A_W - 1:0] rdaddr              ;  //ram rdaddr
    reg     [A_W : 0]   rd_bin              ;
    wire    [A_W : 0]   rd_bin_next         ;

    reg     [A_W : 0]   rd_ptr              ;  //for wr sync; gray code
    reg     [A_W : 0]   rd_ptr_reg1         ;
    reg     [A_W : 0]   rd_ptr_reg2         ;



    //--------------------------------------------------------------------------
    //FIFO WR LOGIC:
    //              rd_ptr synchronizing to wrclk domain
    //--------------------------------------------------------------------------

    function [A_W:0]int_to_gray;
      input [A_W:0]int_var;
      begin
        int_to_gray = (int_var >> 1) ^ int_var;
      end
    endfunction

    function [A_W:0]gray_to_int;
      input [A_W:0]gray_value;
      reg   [A_W:0] temp1;
      reg   [A_W:0] temp2;
      reg   [A_W:0] temp3;
      reg   [A_W:0] temp4;
      reg   [A_W:0] temp5;
      begin
         temp1 = (gray_value >> 16) ^ gray_value;
         temp2 = (temp1 >> 8) ^ temp1;
         temp3 = (temp2 >> 4) ^ temp2;
         temp4 = (temp3 >> 2) ^ temp3;
         temp5 = (temp4 >> 1) ^ temp4;
         gray_to_int = temp5;
      end
    endfunction

    //----------------------------------------------------------------------------------
    //FIFO WR LOGIC:
    //              wr_ptr gray code gen, for safe transfor at the cross-clk domain 
    //              ram wraddr gen, binary counter for mem wr addressing
    //-----------------------------------------------------------------------------------


    assign wr_bin_next = wr_bin + wren;
    always @(posedge wrclk or negedge wr_rst)
    begin
      if(!wr_rst)
        begin
          wr_bin <= {A_W{1'b0}};
          wr_ptr <= {A_W{1'b0}};
        end
      else if(!wr_soft_rst)
        begin
          wr_bin <= {A_W{1'b0}};
          wr_ptr <= {A_W{1'b0}};       
        end
      else
        begin
          wr_bin <= wr_bin_next;
          wr_ptr <= int_to_gray(wr_bin_next);
        end
    end

    assign wren   = wrreq;
    assign wraddr = wr_bin[A_W - 1:0];


    always @(posedge wrclk or negedge wr_rst)
    begin
      if(!wr_rst)
        begin
          rd_ptr_reg1 <= {A_W{1'b0}};
          rd_ptr_reg2 <= {A_W{1'b0}};
        end
      else if(!wr_soft_rst)
        begin
          rd_ptr_reg1 <= {A_W{1'b0}};
          rd_ptr_reg2 <= {A_W{1'b0}};
        end        
      else
        begin
          rd_ptr_reg1 <= rd_ptr;
          rd_ptr_reg2 <= rd_ptr_reg1;
        end
    end
 
 
    always @(posedge wrclk or negedge wr_rst)
    begin
      if(!wr_rst)
        wrusedw <= {A_W{1'b0}};
      else if(!wr_soft_rst)
        wrusedw <= {A_W{1'b0}};
      else
        wrusedw <= wr_bin_next - gray_to_int(rd_ptr_reg2);
    end
 
    assign wrfull  = wrusedw[A_W];
    assign wrempty = (wrusedw == {A_W{1'b0}})?1'b1:1'b0;

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //------------------------------------------------------------------------------
    //FIFO RD LOGIC:
    //              rd_ptr gray code gen, for safe transfer at the corss-clk domain
    //              ram rdaddr gen, binary counter for mem rd addressing
    //              ram rden gen, rd processing when mem is  !empty and rdreq valid
    //-------------------------------------------------------------------------------
    
    assign rd_bin_next = rd_bin + rden;
    
    always @(posedge rdclk or negedge rd_rst)
    begin
      if(!rd_rst)
        begin
          rd_bin <= {A_W{1'b0}};
          rd_ptr <= {A_W{1'b0}};
        end
      else if(!rd_soft_rst)
        begin
          rd_bin <= {A_W{1'b0}};
          rd_ptr <= {A_W{1'b0}};
        end
      else
        begin
          rd_bin <= rd_bin_next;
          rd_ptr <= int_to_gray(rd_bin_next);
        end
    end

    assign rden   = rdreq;
    assign rdaddr = rd_bin[A_W - 1:0];


    always @(posedge rdclk or negedge rd_rst)
    begin
      if(!rd_rst)
        begin
          wr_ptr_reg1 <=  {A_W{1'b0}};
          wr_ptr_reg2 <=  {A_W{1'b0}};
        end
      else if(!rd_soft_rst)
        begin
          wr_ptr_reg1 <=  {A_W{1'b0}};
          wr_ptr_reg2 <=  {A_W{1'b0}};
        end        
      else
        begin
          wr_ptr_reg1 <=  wr_ptr;
          wr_ptr_reg2 <=  wr_ptr_reg1;
        end
    end

    always @(posedge rdclk or negedge rd_rst)
    begin
      if(!rd_rst)
        rdusedw <= {A_W{1'b0}};
      else if(!rd_soft_rst)
        rdusedw <= {A_W{1'b0}};
      else
        rdusedw <= gray_to_int(wr_ptr_reg2) - rd_bin_next;
    end
 
    assign rdfull  = rdusedw[A_W];
    assign rdempty = (rdusedw == {A_W{1'b0}})?1'b1:1'b0;    


//-------------------- dual ram and bist--------------------
/*
FPGA_FIFO_256_DP_RAM_256X8 FPGA_FIFO_256_DP_RAM_256X8(
   .address_a(wraddr),
   .address_b(rdaddr),
   .clock_a(wrclk),
   .clock_b(rdclk),
   .data_a(data),
   .data_b(8'h0),
   .enable_a(1'b1 & wren),
   .enable_b(rden),
   .wren_a(wren),
   .wren_b(1'b0),
   .q_a(),
   .q_b(q)
   );
   */

FIFO_DP_RAM_256X8_COLLAR FIFO_DP_RAM_256X8_COLLAR(
   .address_a(wraddr),
   .address_b(rdaddr),
   .clock_a  (wrclk),
   .clock_b  (rdclk),
   .data_a   (data),
   .data_b   (8'h0),
   .enable_a (1'b1 & wren),
   .enable_b (rden),
   .wren_a   (wren),
   .wren_b   (1'b0),
   .q_a      (),
   .q_b      (q)
   );
   
/*
FIFO_256_DP_RAM_256X8_bist_con FIFO_256_DP_RAM_256X8_bist_con(
       .tst_done (mb_done), 
       .fail_h   (mb_fail), 
       .test_h   (mb_enable),
       .bist_clk (wrclk), 
       .rst_l    (wr_rst),
       .TM_BYPASS(test_mode),
       .MB_BYPASS(mb_bypass), 
       .QB       (q), 
       .QA       (), 
       .CLKA     (wrclk), 
       .CLKB     (rdclk), 
       .DA       (data), 
       .DB       (8'h0), 
       .AA       (wraddr), 
       .AB       (rdaddr), 
       .WENA     (!wren), 
       .WENB     (1'b1), 
       .CENA     (!wren), 
       .CENB     (!rden)
);
*/
endmodule