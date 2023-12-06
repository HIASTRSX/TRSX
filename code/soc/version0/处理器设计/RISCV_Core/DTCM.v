module DTCM
#(
    parameter DP = 256,
    //parameter FORCE_X2ZERO = 0,
    parameter DW = 32,
    //parameter MW = 4,
    parameter AW = 32
)
(
    input                  clk,
    input                  rst_n,

    //数据存入读取接口
    input                   mem_cs,
    input                   mem_wr,
    input       [3:0]       mem_bwen,
    input       [AW-1:0]    mem_addr,
    input       [DW-1:0]    mem_data,
    output reg  [DW-1:0]    mem_data_wb
);
reg [DW-1:0] mem_r [0:DP-1];

always @ ( posedge clk )
begin
    if ( mem_cs & mem_wr )
    begin
      if ( mem_bwen[0] )  mem_r[mem_addr][07:00] <= mem_data[07:00];
      if ( mem_bwen[1] )  mem_r[mem_addr][15:08] <= mem_data[15:08];
      if ( mem_bwen[2] )  mem_r[mem_addr][23:16] <= mem_data[23:16];
      if ( mem_bwen[3] )  mem_r[mem_addr][31:24] <= mem_data[31:24];
    end
end

always @ ( posedge clk or negedge rst_n )
begin
  if ( ~rst_n )
    mem_data_wb <= 32'b0;
  else if ( mem_cs & ( ~mem_wr ) )
    mem_data_wb <= mem_r[mem_addr];
end


endmodule