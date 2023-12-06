`include "risc_v_defines.v"

module sim_ram 
#(
    parameter DP = 256,
    //parameter FORCE_X2ZERO = 0,
    parameter DW = 32,
    //parameter MW = 4,
    parameter AW = 32
)
(
    //指令读取接口
    input                  clk,
    input                  rst_n,
    //input  [DW-1:0]     din,
    input       [AW-1:0]   addr,
    input                  cs,
    //input               we,
    //input  [MW-1:0]     wem,
    output      [DW-1:0]   dout

    //数据存入读取接口
    //input                   mem_cs,
    //input                   mem_wr,
    //input       [3:0]       mem_bwen,
    //input       [AW-1:0]    mem_addr,
    //input       [DW-1:0]    mem_data,
    //output reg  [DW-1:0]    mem_data_wb


);
reg [DW-1:0] mem_r [0:DP-1];
reg [AW-1:0] addr_r;
//wire [MW-1:0] wen;
wire ren;

//assign ren = cs & (~we);
assign ren = cs;
//assign wen = ({MW{cs & we}} & wem);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        addr_r <= `address_sim;
    end    
    else if(ren) begin
        addr_r <= addr;
    end
end

//initial begin
//    $readmemh("E:/risc_v_core/test_insr/rv32ui-p-and", mem_r);
//end

/*
genvar i;

generate
    for(i = 0; i < MW; i = i+1) begin :mem
        if ((8*i+8) > DW) begin :last
            always @(posedge clk) begin
                if(wen[i]) begin
                    mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
                end
            end
        end
        else begin: non_last
            always @(posedge clk) begin
                if(wen[i]) begin
                    mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
                end
            end
        end

    end
endgenerate
*/
assign dout = mem_r[addr_r];
/*
always @ ( posedge clk )
begin
//  if ( ~rst_n )
//    for (i=0;i<2**AW;i=i+1)
//      mem_cell[i] <= 32'b0;
//  else if ( cs & wr )
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
*/
endmodule