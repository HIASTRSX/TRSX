`include "risc_v_defines.vh"
module CSRFile (
    
    clk,
    rst_n,

    CSR_IDX,  
    csr_data,

    CSR_IDX_wb,
    CSRdata_wb,
    CSRen_wb,

    trap_entry_en,
    trap_exit_en,
    trap_entry_pc,
    restore_pc,
    normal_pc,
    int_index,
    int_mstatus_mie

    //SD_raddr,     
    //SD_sec_counts,
    //SD_read,
    //dma_waddr
);
input                           clk;
input                           rst_n;
//CSR读出信号
input   [11:0]                  CSR_IDX;
output  [31:0]                  csr_data;

//CSR写回信号
input   [11:0]                  CSR_IDX_wb;
input   [`rv32_XLEN-1:0]        CSRdata_wb;
input                           CSRen_wb;

input                           trap_entry_en;
input                           trap_exit_en;
output  [`PC_WIDTH-1:0]         trap_entry_pc;
output  [`PC_WIDTH-1:0]         restore_pc;
input   [`PC_WIDTH-1:0]         normal_pc;
input   [ 3:0]                  int_index;
output                          int_mstatus_mie;

//output  [31:0]                  SD_raddr;       // 读取SD的起始地址
//output  [31:0]                  SD_sec_counts;  // 读取SD的扇区数，每个扇区512 bytes数据
//output  [31:0]                  SD_read;        // 读取SD使能信号，上升沿有效，拉高后，下次再设置前，需要先拉低
//output  [31:0]                  dma_waddr;      // 控制DMA将SD读取的数据写入哪块地址

reg     [63:0] mcycle;
reg     [31:0] mstatus;
reg     [31:0] mtvec;
reg     [31:0] mepc;
reg     [31:0] mcause;
reg     [31:0] mscratch;
//reg     [31:0] m_sdaddr;
//reg     [31:0] m_sec_counts;
//reg     [31:0] m_sdread;
//reg     [31:0] m_waddr;

wire    [31:0] mcycle_h_val;
wire    [31:0] mcycle_l_val;
wire    [31:0] mstatus_val;
wire    [31:0] mtvec_val;
wire    [31:0] mepc_val;
wire    [31:0] mcause_val;
wire    [31:0] mscratch_val;
//wire    [31:0] msdaddr_val;
//wire    [31:0] mseccounts_val;
//wire    [31:0] msdread_val;
//wire    [31:0] mwaddr_val;

assign mcycle_l_val     = CSR_IDX == 12'hb00 ? mcycle[31:0] : 32'b0;
assign mcycle_h_val     = CSR_IDX == 12'hb80 ? mcycle[63:32] : 32'b0;
assign mstatus_val      = CSR_IDX == 12'h300 ? mstatus : 32'b0;
assign mtvec_val        = CSR_IDX == 12'h305 ? mtvec : 32'b0;
assign mepc_val         = CSR_IDX == 12'h341 ? mepc : 32'b0;
assign mcause_val       = CSR_IDX == 12'h342 ? mcause : 32'b0;
assign mscratch_val     = CSR_IDX == 12'h340 ? mscratch : 32'b0;
//assign msdaddr_val      = CSR_IDX == 12'hbfc ? m_sdaddr : 32'b0;
//assign mseccounts_val   = CSR_IDX == 12'hbfd ? m_sec_counts : 32'b0;
//assign msdread_val      = CSR_IDX == 12'hbfe ? m_sdread : 32'b0;
//assign mwaddr_val       = CSR_IDX == 12'hbff ? m_waddr : 32'b0;

//assign SD_raddr         = m_sdaddr;     
//assign SD_sec_counts    = m_sec_counts;
//assign SD_read          = m_sdread;      
//assign dma_waddr        = m_waddr;    

assign csr_data     = CSRen_wb & (CSR_IDX == CSR_IDX_wb) ? CSRdata_wb :
                    (mcycle_l_val | mcycle_h_val | mstatus_val | mtvec_val | mepc_val | mcause_val
                    | mscratch_val ); //| msdaddr_val | mseccounts_val | msdread_val | mwaddr_val);


//mstatus --- Machine status register only impliement [3]mie & [7]mpie
assign int_mstatus_mie = mstatus[3];
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        mstatus <= 32'b00000000;
    else begin
        if (CSRen_wb & (CSR_IDX_wb == 12'h300)) mstatus <= CSRdata_wb;
        if (trap_entry_en) begin
            mstatus[7] <= mstatus[3];       //mie->mpie
            mstatus[3] <= 1'b0;             //mie=0
        end
        if (trap_exit_en) begin
            mstatus[3] <= mstatus[7];       //mpie->mie
            mstatus[7] <= 1'b1;             //mpie=1
        end
    end
end

//mtvec  --- Machine trap-handler base address
assign trap_entry_pc = mtvec;
always @ ( posedge clk or negedge rst_n )
begin
  if ( ~rst_n )
    mtvec <= 32'h20000064;
  else if ( CSRen_wb & (CSR_IDX_wb == 12'h305) )
    mtvec <= CSRdata_wb;
end

//mepc  --- Machine exception program counter
// dffl #(.DW(`rv32_XLEN)) mepc_dffl (mepc, 1'b1, restore_pc, clk, rst_n);\
assign restore_pc = mepc;
always @ ( posedge clk or negedge rst_n )
begin
  if ( ~rst_n )
    mepc <= 32'h0;
  else begin
    if ( CSRen_wb & ( CSR_IDX_wb == 12'h341 ) ) mepc <= CSRdata_wb;
    if ( trap_entry_en )            mepc <= normal_pc;
  end
end

//mcause --- Machine trap cause
always @ ( posedge clk or negedge rst_n )
begin
  if ( ~rst_n )
    mcause <= 32'h0;
  else begin
  if ( CSRen_wb & ( CSR_IDX_wb == 12'h342 ) ) mcause <= CSRdata_wb;
  if ( trap_entry_en )
    begin
      mcause[31]  <= 1'b1;
      mcause[3:0] <= int_index;
    end
  end
end

//Cycle counter
always @ ( posedge clk or negedge rst_n )
begin
  if (~rst_n)
    mcycle <= 64'b0;
  else
    mcycle <= mcycle + 1'b1;
end

always @ ( posedge clk or negedge rst_n )
begin
  if ( ~rst_n )
    mscratch <= 32'h0;
  else begin
    if ( CSRen_wb & ( CSR_IDX_wb == 12'h340 ) ) mscratch <= CSRdata_wb;
  end
end

/*
always @ ( posedge clk or negedge rst_n )
begin
  if ( ~rst_n )
    m_sdaddr      <= 32'd0;
    m_sec_counts  <= 32'd0;
    m_sdread      <= 32'd0;
    m_waddr       <= 32'd0;
  else begin
    if ( CSRen_wb & (CSR_IDX_wb == 12'hbfc) ) m_sdaddr      <= CSRdata_wb;
    if ( CSRen_wb & (CSR_IDX_wb == 12'hbfd) ) m_sec_counts  <= CSRdata_wb;
    if ( CSRen_wb & (CSR_IDX_wb == 12'hbfe) ) m_sdread      <= CSRdata_wb;
    if ( CSRen_wb & (CSR_IDX_wb == 12'hbff) ) m_waddr       <= CSRdata_wb;
  end
end  */

endmodule