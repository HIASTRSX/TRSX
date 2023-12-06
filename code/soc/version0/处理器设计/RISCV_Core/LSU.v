`include "risc_v_defines.v"
module LSU (
    
    input                               clk,
    input                               rst_n,
    //ID模块得到的译码信号
    input                               MemRead,
    input                               MemWrite,
    input   [`DECINFO_L_S_WIDTH-1:0]    mem_info_bus,
    input   [`rv32_XLEN-1:0]            EX_res,        //EX模块运算得到的地址值
    input   [`rv32_XLEN-1:0]            rs2_data,      //Store指令，要写入存储器的数据，即rs2_data
    input   [`RF_IDX_WIDTH-1:0]         rv32_rd,       //Load指令，要写入的RF标号     
    //写回给RF的信号
    output  [`rv32_XLEN-1:0]            Mdata_wb,      //要写入RF的数据，from mem，但等一个时钟周期后才能得到，
    output                              Men_wb,        //注意en、rd时序，需要根据rdata有效打多拍
    output  [`RF_IDX_WIDTH-1:0]         Mrd_wb,

    //AHB master signals
    output  [31:0]                      d_haddr  ,
    output  [3:0]                       d_hprot  ,
    output  [1:0]                       d_htrans ,
    output                              d_hwrite ,
    output  [2:0]                       d_hsize  ,
    output  [2:0]                       d_hburst ,
    output  [31:0]                      d_hwdata ,
    input   [31:0]                      d_hrdata ,      //Load指令，来自mem的数据，写入RF
    //input   [1:0]                       d_hresp,
    input                               d_hready,

    output                              d_ITCM      //LS访问ITCM信号，表示需要拉低取指信号         

);

wire [`rv32_XLEN-1:0]   mem_addr;
wire [2:0]              hsize_r;
wire [2:0]              hsize_w;
wire [`rv32_XLEN-1:0]   mem_data_ready;
wire [`rv32_XLEN-1:0]   mem_data;      //Store指令，要写入存储器的数据，即rs2_data

assign mem_addr =   EX_res;
assign hsize_r  =   3'b010;
assign hsize_w  =   ({3{mem_info_bus[`DECINFO_Stor_SW]}} & 3'b010) | 
                    ({3{mem_info_bus[`DECINFO_Stor_SH]}} & 3'b001) ;
                 //  | ({3{mem_info_bus[`DECINFO_Stor_SB]}} & 3'b000)
assign d_htrans =   (MemRead | MemWrite) ? 2'b10 : 2'b00;
assign d_haddr  =   EX_res;
assign d_hprot  =   4'b0011;
assign d_hwrite =   MemWrite;
assign d_hsize  =   MemWrite ? hsize_w : hsize_r;
assign d_hburst =   3'b000;
//ITCM:0x0000_0000——0x0000_ffff    DTCM:0x2000_0000——0x2000_ffff
//UART:0x4000_0000——0x4000_ffff
assign d_ITCM   =   d_htrans[1] & d_hready & (~|d_haddr[30:29]);
//-----------------------------store-------------------------------
assign mem_data =   ( {`rv32_XLEN{mem_info_bus[`DECINFO_Stor_SW]}} & rs2_data )
                  | ( {`rv32_XLEN{mem_info_bus[`DECINFO_Stor_SH]}} & ( mem_addr[1] ? {rs2_data[15:0], 16'b0} : rs2_data ) )
                  | ( {`rv32_XLEN{mem_info_bus[`DECINFO_Stor_SB]}} & ( ({`rv32_XLEN{~(|mem_addr[1:0])}} & {24'b0,rs2_data[7:0]}) 
                  | ({`rv32_XLEN{(~mem_addr[1] & mem_addr[0])}} & {16'b0,rs2_data[7:0],8'b0}) | ({`rv32_XLEN{(mem_addr[1] & ~mem_addr[0])}} & {8'b0,rs2_data[7:0],16'b0}) 
                  | ({`rv32_XLEN{&mem_addr[1:0]}} & {rs2_data[7:0],24'b0}) )  ) ;
  
//mem_data_ready:ready为高时，将要写入的数据发送给d_hwdata        
dffl #(.DW(`rv32_XLEN)) mem_data_dffl (mem_data, d_hready, mem_data_ready, clk, rst_n);
assign d_hwdata =   mem_data_ready;

//------------------------------load-------------------------------
//load指令,由于mem_data_wb比其他写回信号晚一个时钟周期，故需要对其他信号延迟一个时钟周期
wire [`DECINFO_L_S_WIDTH-1:0]   mem_info_bus_wb_r;
wire [`rv32_XLEN-1:0]           memaddr_wb;
wire                            Men_wb_r;
//发送地址以及写信号后，若ready为低，则addr、info_bus、rd一直为高，持续到ready为高的第一个clk，
//ready为高时，数据已经读出，开始写回
dffl #(.DW(`rv32_XLEN)) mem_addr_dffl (mem_addr, d_hready, memaddr_wb, clk, rst_n);
dffl #(.DW(`DECINFO_L_S_WIDTH)) mem_info_bus_wb_dffl (mem_info_bus, d_hready, mem_info_bus_wb_r, clk, rst_n);
dffl #(.DW(`RF_IDX_WIDTH)) MEMrd_wb_dffl (rv32_rd, d_hready, Mrd_wb, clk, rst_n);
//ready为低期间，Men_wb_r一直为高，写回信号只能ready拉高第一个周期有效，故(Men_wb_r & d_hready)
dffl #(.DW(1)) MEMen_wb_dffl (MemRead, d_hready, Men_wb_r, clk, rst_n);
assign Men_wb   =   (|Mrd_wb) ? (Men_wb_r & d_hready) : 1'b0;

assign Mdata_wb =   ( {`rv32_XLEN{mem_info_bus_wb_r[`DECINFO_LOAD_LB]}} & (  ({32{~(|memaddr_wb[1:0])}} & {{24{d_hrdata[7]}},d_hrdata[7:0]}) 
                  | ({32{~memaddr_wb[1] & memaddr_wb[0]}} & {{24{d_hrdata[15]}},d_hrdata[15:8]}) 
                  | ({32{memaddr_wb[1] & ~memaddr_wb[0]}} & {{24{d_hrdata[23]}},d_hrdata[23:16]}) 
                  | ({32{&memaddr_wb[1:0]}} & {{24{d_hrdata[31]}},d_hrdata[31:24]})  ) ) 
                  | (  {`rv32_XLEN{mem_info_bus_wb_r[`DECINFO_LOAD_LH]}} & (  ({32{~memaddr_wb[1]}} & {{16{d_hrdata[15]}},d_hrdata[15:0]})
                  | ({32{memaddr_wb[1]}} & {{16{d_hrdata[31]}},d_hrdata[31:16]})     ) )
                  | ({`rv32_XLEN{mem_info_bus_wb_r[`DECINFO_LOAD_LW]}} & {d_hrdata[31:0]})
                  | ({`rv32_XLEN{mem_info_bus_wb_r[`DECINFO_LOAD_LBU]}} &  (   ({32{~(|memaddr_wb[1:0])}} & {{24{1'b0}},d_hrdata[7:0]})
                  | ({32{~memaddr_wb[1] & memaddr_wb[0]}} & {{24{1'b0}},d_hrdata[15:8]}) 
                  | ({32{memaddr_wb[1] & ~memaddr_wb[0]}} & {{24{1'b0}},d_hrdata[23:16]})
                  | ({32{&memaddr_wb[1:0]}} & {{24{1'b0}},d_hrdata[31:24]})             ) )
                  | ({`rv32_XLEN{mem_info_bus_wb_r[`DECINFO_LOAD_LHU]}} &  ( ({32{~memaddr_wb[1]}} & {{16{1'b0}},d_hrdata[15:0]})     
                  | ({32{memaddr_wb[1]}} & {{16{1'b0}},d_hrdata[31:16]}) ) )        ;
    
endmodule