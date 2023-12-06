module apb_to_sram #(
    
 parameter     ADDRWIDTH = 16) 
 (
    
  //input  wire                 PCLK,      // Clock
  //input  wire                 PRESETn,   // Reset

                                         // APB Output
  input  wire [ADDRWIDTH-1:0] PADDR,     // APB Address
  input  wire                 PENABLE,   // APB Enable
  input  wire           [3:0] PSTRB,     // APB Byte Strobe
  input  wire           [2:0] PPROT,     // APB Prot
  input  wire                 PWRITE,    // APB Write
  input  wire          [31:0] PWDATA,    // APB write data
  input  wire                 PSEL,      // APB Select

  output wire          [31:0] PRDATA,    // APB Input
  output wire                 PREADY,
  output wire                 PSLVERR,

  input  wire          [31:0] SRAMRDATA, // SRAM Read Data
  output wire [ADDRWIDTH-3:0] SRAMADDR,  // SRAM address
  output wire           [3:0] SRAMWEN,   // SRAM write enable (active high)
  output wire          [31:0] SRAMWDATA, // SRAM write data
  output wire                 SRAMCS);   // SRAM Chip Select  (active high)  

//--------------------------------------------
wire   read_enable  = PSEL & (~PWRITE);           // assert for whole APB read transfer
assign write_enable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer

assign SRAMCS         =       read_enable | write_enable;
assign SRAMADDR       =       PADDR[ADDRWIDTH-1:2];   
assign SRAMWEN        =       PSTRB;
assign SRAMWDATA      =       PWDATA;
assign PRDATA         =       (read_enable) ? SRAMRDATA : {32{1'b0}}; 

assign PREADY         =       1'b1; // Always ready
assign PSLVERR        =       1'b0; // Always okay    


endmodule