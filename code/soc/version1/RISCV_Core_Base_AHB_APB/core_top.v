`include "risc_v_defines.vh"

module core_top (
    
    clk,
    rst_n,

    //指令数据接口
    i_haddr,
    i_hprot,
    i_htrans,
    i_hsize,
    i_hburst,
    i_hready,
    i_hrdata,
    i_hrespi,
    i_hsel,

    d_haddr  ,
    d_hprot  ,
    d_htrans ,
    d_hwrite ,
    d_hsize  ,
    d_hburst ,
    d_hwdata ,
    d_hrdata ,
    d_hready ,

    key1,
    key2,
    key3,
    timer

);
input   clk;
input   rst_n;

output  [`PC_WIDTH-1:0]         i_haddr;
output  [3:0]                   i_hprot;
output  [1:0]                   i_htrans;
output  [2:0]                   i_hsize;
output  [2:0]                   i_hburst;
input                           i_hready;
input   [`rv32_XLEN-1:0]        i_hrdata;
input   [1:0]                   i_hrespi;
output                          i_hsel;

//AHB master signals
output  [31:0]                  d_haddr  ;
output  [3:0]                   d_hprot  ;
output  [1:0]                   d_htrans ;
output                          d_hwrite ;
output  [2:0]                   d_hsize  ;
output  [2:0]                   d_hburst ;
output  [31:0]                  d_hwdata ;
input   [31:0]                  d_hrdata ;     //Load指令，来自mem的数据，写入RF
//input   [1:0]                   d_hresp ;
input                           d_hready ;    

input                           key1;
input                           key2;
input                           key3;
input                           timer;

wire    [`PC_WIDTH-1:0]         PC;
wire    [`ADDR_Bpu_WIDTH-1:0]   prdt_pc_add_op1;
wire    [`ADDR_Bpu_WIDTH-1:0]   prdt_pc_add_op2;

wire                            div_alu_time;
//from ID, data zarad, write flag
wire                            wr_stop1;   //wr_stop的第�?个上升沿  
wire                            wr_stop1_r;    
dffl #(.DW(1)) wr_stop1_dffl (wr_stop1, d_hready, wr_stop1_r, clk, rst_n);
wire                            wr_stop;
assign wr_stop  =               wr_stop1 | (wr_stop1_r & ~d_hready);

wire    [`PC_WIDTH-1:0]         IF_ID_pc;
assign PC   =                   i_haddr;
dffl #(.DW(`PC_WIDTH)) IF_ID_reg(PC, 1'b1, IF_ID_pc, clk, rst_n);

//当d_hready为低时，ID保留当前指令，若当前指令译码为jal、jalr、auipc指令�?
//�?要保留jal、jalr指令的PC，�?�过加法将下�?条指令（jal、jalr指令下一条）赋�?�给x1寄存�?
wire    [`PC_WIDTH-1:0]         IF_ID_pc_ready;
wire    [`PC_WIDTH-1:0]         ID_pc;
dffl #(.DW(`PC_WIDTH)) IF_ID_ready_reg(IF_ID_pc, d_hready, IF_ID_pc_ready, clk, rst_n);

assign ID_pc    =               d_hready ? IF_ID_pc : IF_ID_pc_ready;      
wire                            if_Jump;

//中断接口
wire    [`PC_WIDTH-1:0]         normal_PC;
wire                            trap_entry_en;
wire                            trap_exit_en;
wire    [`PC_WIDTH-1:0]         trap_entry_pc;
wire    [`PC_WIDTH-1:0]         restore_pc;
wire                            d_ITCM;
wire                            d_ITCM_r;
dffl #(.DW(1)) d_ITCM_dffl (d_ITCM, 1'b1, d_ITCM_r, clk, rst_n);

IF IF_u (

    .clk                    (clk),
    .rst_n                  (rst_n),

    .if_Jump                (if_Jump), //取代 prdt_taken
    .prdt_pc_add_op1        (prdt_pc_add_op1),
    .prdt_pc_add_op2        (prdt_pc_add_op2),

    .i_haddr                (i_haddr    ),
    .i_hprot                (i_hprot    ),
    .i_htrans               (i_htrans   ),
    .i_hsize                (i_hsize    ),
    .i_hburst               (i_hburst   ),
    .i_hready               (i_hready   ),
    .i_hrespi               (i_hrespi   ),
    .i_hsel                 (i_hsel     ),
    
    .d_hready               (d_hready   ),  //from EX下一clk，为低说明L/S指令在等待，保持PC当前�?

    .div_alu_time           (div_alu_time),
    //from ID,data zarad, write flag
    .wr_stop                (wr_stop),

    .normal_PC              (normal_PC    ),
    .trap_entry_en          (trap_entry_en),
    .trap_exit_en           (trap_exit_en ),
    .trap_entry_pc          (trap_entry_pc),
    .restore_pc             (restore_pc   ),

    .d_ITCM                 (d_ITCM       ),
    .d_ITCM_r               (d_ITCM_r     )
);


wire    [`RF_IDX_WIDTH-1:0]     rv32_rd;
wire    [`RF_IDX_WIDTH-1:0]     rv32_rs1;
wire    [`RF_IDX_WIDTH-1:0]     rv32_rs2;

// ouput to EX
wire [`RF_IDX_WIDTH-1:0]        rv32_rd2EX;
wire                            ID_EX_RegWrite;
wire [`RF_IDX_WIDTH-1:0]        EX_MEM_Rd;
wire                            EX_MEM_RegWrite;
wire                            if_stop_EX;
wire                            if_stop_MEM;
wire [`RF_IDX_WIDTH-1:0]        rd_wb;
wire                            en_wb;
wire [`rv32_XLEN-1:0]           rv32_insr;
wire [`rv32_XLEN-1:0]           rv32_insr_r;
dffl #(.DW(`rv32_XLEN)) dffl_insr (rv32_insr, 1'b1, rv32_insr_r, clk, rst_n);
//from RF,register write flag, stop flag
wire [`RF_REG_NUM-1:0]          stop_flag;
wire                            RegWrite_all;

wire [`rv32_XLEN-1:0]           rs1_data;
wire [`rv32_XLEN-1:0]           rs2_data;

wire [`DECINFO_M_D_WIDTH-1:0]   muldiv_info_bus;
wire  [`rv32_XLEN-1:0]          Op1;
wire  [`rv32_XLEN-1:0]          Op2;
wire                            Addcin;
wire                            MUL_sig;
wire  [`EN_Wid-1 : 0]           Op_En;
wire  [`rv32_XLEN:0]            a_opuns;
wire  [`rv32_XLEN:0]            b_opuns;
wire                            DIVsign;
wire  [5:0]                     N1;
wire  [5:0]                     N2;
wire                            RegWrite;

wire                            MemRead;
wire                            MemWrite;
wire  [`DECINFO_L_S_WIDTH-1:0]  mem_info_bus;

//与csr寄存器接�?
wire  [`DECINFO_CSR_WIDTH-1:0]  csr_info_bus;
wire  [11:0]                    CSR_IDX;
wire  [31:0]                    csr_data;
wire                            csr_wb;      //csr寄存器写回使能信�?
wire                            mret_en;

ID ID_u (
    .rv32_insr_mem          (i_hrdata),                         //from ram,根据PC地址选�?�的Insr
    .rv32_insr              (rv32_insr),                        //将该周期的Insr输出，给寄存�?
    .rv32_insr_mem_r        (rv32_insr_r),                      //if div insr, stall
    
    //To Regfile                                
    .rv32_rs1               (rv32_rs1),
    .rv32_rs2               (rv32_rs2),
    
    //from RF, write flag
    .stop_flag              (stop_flag),
    .RegWrite_all           (RegWrite_all),     
    .wr_stop1               (wr_stop1),

    //jump_branch
    .PC                     (ID_pc),
    .if_Jump                (if_Jump),      //To IF
    .prdt_pc_add_op1        (prdt_pc_add_op1),
    .prdt_pc_add_op2        (prdt_pc_add_op2),
    .rs1_data               (rs1_data),
    .rs2_data               (rs2_data),

    //To EX_TOP2中EX,译码操作�?
    .muldiv_info_bus        (muldiv_info_bus),
    .Op1                    (Op1            ),
    .Op2                    (Op2            ),
    .Addcin                 (Addcin         ),
    .MUL_sig                (MUL_sig        ),
    .Op_En                  (Op_En          ),
    .a_opuns                (a_opuns        ),
    .b_opuns                (b_opuns        ),
    .DIVsign                (DIVsign        ),
    .N1                     (N1             ),
    .N2                     (N2             ),
    .RegWrite               (RegWrite       ),
    .div_alu_time           (div_alu_time   ),
    // ouput to EX LSU
    .MemRead                (MemRead        ),              
    .MemWrite               (MemWrite       ),
    .mem_info_bus           (mem_info_bus   ),
    .rv32_rd                (rv32_rd        ),

    .i_hready               (i_hready       ),

    .d_hready               (d_hready       ),

    //与csr寄存器接�?
    .csr_info_bus           (csr_info_bus   ),
    .CSR_IDX                (CSR_IDX        ),     
    .csr_data               (csr_data       ),
    .csr_wb                 (csr_wb         ),     
    .mret_en                (mret_en        ),

    .d_ITCM_r               (d_ITCM_r       ),
    .d_ITCM                 (d_ITCM         )
);

//EX执行结果写回端口
wire [`RF_IDX_WIDTH-1:0]          EXrd_wb;
wire [`rv32_XLEN-1:0]             EXdata_wb;
wire                              EXen_wb;
//wbck load指令，RF中写入mem中数�?
wire [`rv32_XLEN-1:0]             Mdata_wb;      //要写入RF的数据，from mem，但等一个时钟周期后才能得到�?
wire                              Men_wb;        //注意en、rd时序，需要打�?�?
wire [`RF_IDX_WIDTH-1:0]          Mrd_wb; 

RegFile RegFile_u (

    .clk                    (clk),
    .rst_n                  (rst_n),
    // From ID
    .rv32_rs1_idx           (rv32_rs1),
    .rv32_rs2_idx           (rv32_rs2),
    // Output to EX and ID_Branch
    .read_rs1_data          (rs1_data), 
    .read_rs2_data          (rs2_data),
    //wbck 写入EX执行结果数据
    .wbck_en                (EXen_wb),
    .wbck_dest_idx          (EXrd_wb),
    .wbck_dest_data         (EXdata_wb),
    //wbck load指令，写入mem中数�?
    .Men_wb                 (Men_wb),
    .Mrd_wb                 (Mrd_wb),
    .Mdata_wb               (Mdata_wb),
    //test write register flag,to test data zara
    .rd                     (rv32_rd),
    .RegWrite_all           (RegWrite_all),
    .stop_flag              (stop_flag),
    .wr_stop                (wr_stop)

);

//CSR执行结果写回端口
wire [11:0]                       CSR_IDX_wb;
wire [`rv32_XLEN-1:0]             CSRdata_wb;
wire                              CSRen_wb;

EX_top2 EX_top2_u (

    .clk                    (clk),
    .rst_n                  (rst_n),

    //To EX,译码操作�?
    .muldiv_info_bus        (muldiv_info_bus),
    .Op1                    (Op1            ),
    .Op2                    (Op2            ),
    .Addcin                 (Addcin         ),
    .MUL_sig                (MUL_sig        ),
    .Op_En                  (Op_En          ),
    .a_opuns                (a_opuns        ),
    .b_opuns                (b_opuns        ),
    .DIVsign                (DIVsign        ),
    .N1                     (N1             ),
    .N2                     (N2             ),
    .RegWrite               (RegWrite       ),     //EX执行结果写回控制信号
    .div_alu_time           (div_alu_time   ),
    
    //EX执行结果写回端口
    .EXrd_wb                (EXrd_wb        ),
    .EXdata_wb              (EXdata_wb      ),
    .EXen_wb                (EXen_wb        ),

     //LSU inputs       
    .MemRead                (MemRead        ),
    .MemWrite               (MemWrite       ),
    .mem_info_bus           (mem_info_bus   ),

    .rs2_data               (rs2_data       ),      //Store指令，要写入存储器的数据，即rs2_data
    .rv32_rd                (rv32_rd        ),       //Load指令，要写入的RF标号 

    .Mdata_wb               (Mdata_wb       ),      //要写入RF的数据，from mem，但等一个时钟周期后才能得到�?
    .Men_wb                 (Men_wb         ),        //注意en、rd时序，需要打�?�?
    .Mrd_wb                 (Mrd_wb         ), 
 
    .wr_stop                (wr_stop        ),

    //csr ALU
    .csr_info_bus           (csr_info_bus   ),
    .CSR_IDX                (CSR_IDX        ),
    .csr_wb                 (csr_wb         ),
    //CSR执行结果写回端口
    .CSR_IDX_wb             (CSR_IDX_wb     ),
    .CSRdata_wb             (CSRdata_wb     ),
    .CSRen_wb               (CSRen_wb       ),
    //AHB master signals
    .d_haddr                (d_haddr        ),
    .d_hprot                (d_hprot        ),
    .d_htrans               (d_htrans       ),
    .d_hwrite               (d_hwrite       ),
    .d_hsize                (d_hsize        ),
    .d_hburst               (d_hburst       ),
    .d_hwdata               (d_hwdata       ),      //Store指令，要写入存储器的数据，即rs2_data
    .d_hrdata               (d_hrdata       ),
    .d_hready               (d_hready       ),
    .d_ITCM                 (d_ITCM         ),
    .i_haddr                (IF_ID_pc       )  
);
//------------------------中断调试---------------------------
wire [3:0] int_index;

wire                        int_mstatus_mie;

CSRFile CSRFile_u (

    .clk                    (clk            ),
    .rst_n                  (rst_n          ),

    .CSR_IDX                (CSR_IDX        ),  
    .csr_data               (csr_data       ),

    .CSR_IDX_wb             (CSR_IDX_wb     ),
    .CSRdata_wb             (CSRdata_wb     ),
    .CSRen_wb               (CSRen_wb       ),

    .trap_entry_en          (trap_entry_en  ),
    .trap_exit_en           (trap_exit_en   ),
    .trap_entry_pc          (trap_entry_pc  ),
    .restore_pc             (restore_pc     ),
    .normal_pc              (normal_PC      ),
    .int_index              (int_index      ),
    .int_mstatus_mie        (int_mstatus_mie)
);

interrupt_ctrl interrupt_ctrl_u (
    .clk                    (clk           ),
    .rst_n                  (rst_n         ),
    .key1                   (key1          ),
    .key2                   (key2          ),
    .key3                   (key3          ),

    .int_index              (int_index      ),
    .int_mstatus_mie        (int_mstatus_mie),
    .mret_en                (mret_en        ),
    .trap_entry_en          (trap_entry_en  ),
    .trap_exit_en           (trap_exit_en   ),

    .timer                  (timer          )
);


endmodule