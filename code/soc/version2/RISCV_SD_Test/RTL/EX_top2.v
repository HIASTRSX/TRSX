`include "risc_v_defines.vh"

module EX_top2 (

    input                               clk,
    input                               rst_n,

    //To EX,译码操作数
    input  [`DECINFO_M_D_WIDTH-1:0]     muldiv_info_bus,
    input  [`rv32_XLEN-1:0]             Op1,
    input  [`rv32_XLEN-1:0]             Op2,
    input                               Addcin,
    input                               MUL_sig,
    input  [`EN_Wid-1 : 0]              Op_En,
    input  [`rv32_XLEN:0]               a_opuns,
    input  [`rv32_XLEN:0]               b_opuns,
    input                               DIVsign,
    input  [5:0]                        N1,
    input  [5:0]                        N2,
    input                               RegWrite,     //EX执行结果写回控制信号
    output                              div_alu_time,
    //EX执行结果写回端口
    output [`RF_IDX_WIDTH-1:0]          EXrd_wb,
    output [`rv32_XLEN-1:0]             EXdata_wb,
    output                              EXen_wb,

    //LSU inputs       
    input                               MemRead,
    input                               MemWrite,
    input  [`DECINFO_L_S_WIDTH-1:0]     mem_info_bus,

    input  [`rv32_XLEN-1:0]             rs2_data,      //Store指令，要写入存储器的数据，即rs2_data
    input  [`RF_IDX_WIDTH-1:0]          rv32_rd,       //Load指令，要写入的RF标号 

    //LSU outputs
    output  [`rv32_XLEN-1:0]            Mdata_wb,      //要写入RF的数据，from mem，但等一个时钟周期后才能得到，
    output                              Men_wb,        //注意en、rd时序，因为ready拉低，可能需要打2拍
    output  [`RF_IDX_WIDTH-1:0]         Mrd_wb, 
 
    input                               wr_stop,

    //csr ALU
    input   [`DECINFO_CSR_WIDTH-1:0]    csr_info_bus,
    input   [11:0]                      CSR_IDX,
    input                               csr_wb,

    //CSR执行结果写回端口
    output [11:0]                       CSR_IDX_wb,
    output [`rv32_XLEN-1:0]             CSRdata_wb,
    output                              CSRen_wb,

    //AHB master signals
    output  [31:0]                      d_haddr  ,
    output  [3:0]                       d_hprot  ,
    output  [1:0]                       d_htrans ,
    output                              d_hwrite ,
    output  [2:0]                       d_hsize  ,
    output  [2:0]                       d_hburst ,
    output  [31:0]                      d_hwdata ,   //Store指令，要写入存储器的数据，即rs2_data
    input   [31:0]                      d_hrdata ,   //Load指令，来自mem的数据，写入RF
    //input   [1:0]                       d_hresp  ,
    input                               d_hready ,

    output                              d_ITCM,
    input [`PC_WIDTH-1:0]               i_haddr
);
wire        [`rv32_XLEN-1:0]             Op1_EX;
wire        [`rv32_XLEN-1:0]             Op2_EX;
wire                                     Addcin_EX;
wire                                     MUL_sig_EX;
wire        [`EN_Wid-1:0]                Op_En_EX;
wire        [`rv32_XLEN:0]               a_opuns_EX;
wire        [`rv32_XLEN:0]               b_opuns_EX;
wire                                     DIVsign_EX;
wire        [5:0]                        N1_EX;
wire        [5:0]                        N2_EX;
// -------------------------------------------------------------
wire        [`RF_IDX_WIDTH-1:0]         rv32_rd2EX;
wire                                    RegWrite2EX;  
wire                                    MemRead2EX;   
wire                                    MemWrite2EX;  
wire        [`DECINFO_L_S_WIDTH-1:0]    mem_info_bus2EX;   
wire        [`DECINFO_M_D_WIDTH-1:0]    muldiv_info_bus2EX; 
wire        [`rv32_XLEN-1:0]            rs2_data2EX;

wire        [`DECINFO_CSR_WIDTH-1:0]    csr_info_bus2EX;
wire        [11:0]                      CSR_IDX2EX;
wire                                    csr_wb2EX;
//发生数据冲突导致流水线停顿，若下条指令为除法，要等待传输除法使能信号，否则误触发div_en信号，运算出错
//dfflset #(.DW(`DECINFO_M_D_WIDTH)) muldiv_info_bus_dffl    
//((|{stop_num, if_stop}),muldiv_info_bus, 1'b1, muldiv_info_bus2EX, clk, rst_n);
dfflset #(.DW(`DECINFO_M_D_WIDTH)) muldiv_info_bus_dffl (wr_stop,muldiv_info_bus, 1'b1, muldiv_info_bus2EX, clk, rst_n);
dffl #(.DW(`rv32_XLEN)) Op1_dffl (Op1, 1'b1, Op1_EX, clk, rst_n);
dffl #(.DW(`rv32_XLEN)) Op2_dffl (Op2, 1'b1, Op2_EX, clk, rst_n);
dffl #(.DW(1)) Addcin_dffl (Addcin, 1'b1, Addcin_EX, clk, rst_n);
dffl #(.DW(1)) MUL_sig_dffl (MUL_sig, 1'b1, MUL_sig_EX, clk, rst_n);
dffl #(.DW(`EN_Wid)) Op_En_dffl (Op_En, 1'b1, Op_En_EX, clk, rst_n);
dffl #(.DW(33)) a_opuns_dffl (a_opuns, 1'b1, a_opuns_EX, clk, rst_n);
dffl #(.DW(33)) b_opuns_dffl (b_opuns, 1'b1, b_opuns_EX, clk, rst_n);
dffl #(.DW(1)) DIVsign_dffl (DIVsign, 1'b1, DIVsign_EX, clk, rst_n);
dffl #(.DW(6)) N1_dffl (N1, 1'b1, N1_EX, clk, rst_n);
dffl #(.DW(6)) N2_dffl (N2, 1'b1, N2_EX, clk, rst_n);
dfflset #(.DW(1)) RegWrite_dffl (wr_stop,RegWrite, 1'b1, RegWrite2EX, clk, rst_n);  //加入div_alu_time停顿

dfflset #(.DW(1)) MemRead_dffl (wr_stop,MemRead, 1'b1, MemRead2EX, clk, rst_n);
dfflset #(.DW(1)) MemWrite_dffl (wr_stop,MemWrite, 1'b1, MemWrite2EX, clk, rst_n);
dffl #(.DW(`DECINFO_L_S_WIDTH)) mem_info_bus_dffl (mem_info_bus, 1'b1, mem_info_bus2EX, clk, rst_n);
dffl #(.DW(`rv32_XLEN)) rs2_data_dffl (rs2_data, 1'b1, rs2_data2EX, clk, rst_n);
dffl #(.DW(`RF_IDX_WIDTH)) rv32_rd_dffl (rv32_rd, 1'b1, rv32_rd2EX, clk, rst_n);

dffl #(.DW(`DECINFO_CSR_WIDTH)) csr_info_bus_dffl (csr_info_bus, 1'b1, csr_info_bus2EX, clk, rst_n);
dffl #(.DW(12)) CSR_IDX_dffl (CSR_IDX, 1'b1, CSR_IDX2EX, clk, rst_n);
dfflset #(.DW(1)) csr_wb_dffl (wr_stop,csr_wb, 1'b1, csr_wb2EX, clk, rst_n);

wire    [`rv32_XLEN-1:0]            EX_res;
wire    [`rv32_XLEN-1:0]            addr_res;
EX EX_u (

    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    //d_hready为低时，若下一条指令为除法，不进行除法运算，否则可能发生WAW相关，即除法先写回，load
    //再写回同一rd
    .muldiv_info_bus        (muldiv_info_bus2EX ),

    .Op1                    (Op1_EX             ),
    .Op2                    (Op2_EX             ),
    .Addcin                 (Addcin_EX          ),
    .MUL_sig                (MUL_sig_EX         ),
    .Op_En                  (Op_En_EX           ),
    .a_opuns                (a_opuns_EX         ),
    .b_opuns                (b_opuns_EX         ),
    .DIVsign                (DIVsign_EX         ),
    .N1                     (N1_EX              ),
    .N2                     (N2_EX              ),
    .EX_res                 (EX_res             ),

    .div_alu_time           (div_alu_time       ),
    .addr_res               (addr_res           ),

    .csr_info_bus           (csr_info_bus2EX    ),

    .d_hready               (d_hready           )
);
// ------------------------------EX REs WB-------------------------------

//该写回信号只包括EX写回，不包括load指令，load写回由LSU控制. 当d_hready为低时，说明L/S指令在等待数据
//此时流水线停顿，ID阶段停在下一条指令，为避免多次写入下一条指令，需要暂停EXen_wb
//div_alu_time期间，写使能为0，是为了只在最终得到除法结果时再写入，中间的运算结果不写入
//assign EXen_wb      = (|rv32_rd2EX) & (~div_alu_time) & d_hready ? RegWrite2EX : 1'b0; 
assign EXen_wb      = (|rv32_rd2EX) & (~div_alu_time) & d_hready & RegWrite2EX;
assign EXdata_wb    = EX_res;                             //写回目的寄存器为0时，写回信号为0
assign EXrd_wb      = rv32_rd2EX;                         //避免在写回阶段恰好读取0号寄存器数据时出错

// ------------------------------CSR REs WB-------------------------------
CSR_EX CSR_EX_u (

    .csr_info_bus           (csr_info_bus2EX    ),
    .Op1                    (Op1_EX             ),       
    .Op2                    (Op2_EX             ),       
    .CSR_res                (CSRdata_wb         )
);

//当d_hready为低时，说明L/S指令在等待数据
//此时流水线停顿，ID阶段停在下一条指令，为避免多次写入下一条指令，需要暂停EXen_wb
assign CSR_IDX_wb   = CSR_IDX2EX;
assign CSRen_wb     = d_hready ? csr_wb2EX : 1'b0;

// ---------------------------------LSU----------------------------------    
LSU LSU_u (

    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    
    .MemRead                (MemRead2EX         ),
    .MemWrite               (MemWrite2EX        ),
    .mem_info_bus           (mem_info_bus2EX    ),
    .EX_res                 (addr_res           ),       //EX模块运算得到的地址值
    .rs2_data               (rs2_data2EX        ),

    .rv32_rd                (rv32_rd2EX         ),       //Load指令，要写入的RF标号     

    .Mdata_wb               (Mdata_wb           ),      //要写入RF的数据，from mem，但等一个时钟周期后才能得到，
    .Men_wb                 (Men_wb             ),      //注意en、rd时序，需要打一拍
    .Mrd_wb                 (Mrd_wb             ),

    .d_haddr                (d_haddr            ),
    .d_hprot                (d_hprot            ),
    .d_htrans               (d_htrans           ),
    .d_hwrite               (d_hwrite           ),
    .d_hsize                (d_hsize            ),
    .d_hburst               (d_hburst           ),
    .d_hwdata               (d_hwdata           ),
    .d_hrdata               (d_hrdata           ),
    .d_hready               (d_hready           ),
    .d_ITCM                 (d_ITCM             ),
    .i_haddr                (i_haddr            )            
);
endmodule