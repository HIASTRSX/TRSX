module FIFO_DP_RAM_256X8_COLLAR (
   address_a,
   address_b,
   clock_a  ,
   clock_b  ,
   data_a   ,
   data_b   ,
   enable_a ,
   enable_b ,
   wren_a   ,
   wren_b   ,
   q_a      ,
   q_b      ,
);

parameter  D_W = 8;
parameter  A_W = 8;


input  [A_W-1:0] address_a;
input  [A_W-1:0] address_b;
input            clock_a;
input            clock_b;
input  [D_W-1:0] data_a;
input  [D_W-1:0] data_b;
input            enable_a;
input            enable_b;
input            wren_a;
input            wren_b;
output [D_W-1:0] q_a;
output reg [D_W-1:0] q_b;

reg [D_W-1:0] mem [2**A_W-1:0];

always @ ( posedge clock_a )
  begin
    if ( enable_a & wren_a )
      mem[address_a] <= data_a;
  end

always @ ( posedge clock_b )
  begin
    if ( enable_b & ( ~wren_b) )
      q_b <= mem[address_b];
  end


endmodule