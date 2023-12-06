`include "risc_v_defines.vh"

module ID (

input  [`rv32_XLEN-1:0]             rv32_insr_mem,
output [`rv32_XLEN-1:0]             rv32_insr,
input  [`rv32_XLEN-1:0]             rv32_insr_mem_r,
//control signals

// To RegFile
output [`RF_IDX_WIDTH-1:0]          rv32_rs1,
output [`RF_IDX_WIDTH-1:0]          rv32_rs2,
output                              RegWrite_all,

//from RF,test data zarad
input  [`RF_REG_NUM-1:0]            stop_flag,
output                              wr_stop1,

//Jump_branch
input  [`PC_WIDTH-1:0]              PC,
output [`ADDR_Bpu_WIDTH-1:0]        prdt_pc_add_op1,
output [`ADDR_Bpu_WIDTH-1:0]        prdt_pc_add_op2,
input  [`rv32_XLEN-1:0]             rs1_data,
input  [`rv32_XLEN-1:0]             rs2_data,
output                              if_Jump,

//To EX_TOP2中EX,译码操作数
output [`DECINFO_M_D_WIDTH-1:0]     muldiv_info_bus,
output [`rv32_XLEN-1:0]             Op1,
output [`rv32_XLEN-1:0]             Op2,
output                              Addcin,
output                              MUL_sig,
output [`EN_Wid-1 : 0]              Op_En,
output [`rv32_XLEN:0]               a_opuns,
output [`rv32_XLEN:0]               b_opuns,
output                              DIVsign,
output [5:0]                        N1,
output [5:0]                        N2,
output                              RegWrite,     //EX执行结果写回寄存器使能信号
input                               div_alu_time, //来自EX，除法运算期间，停顿
//To EX_TOP2中LSU
output                              MemRead,
output                              MemWrite,
output [`DECINFO_L_S_WIDTH-1:0]     mem_info_bus,
output [`RF_IDX_WIDTH-1:0]          rv32_rd,

input                               i_hready,   //当i_hready信号拉低时，说明指令还没到，需要执行nop指令

input                               d_hready,   //当d_hready信号拉低时，说明L/S指令正在等待，需保持下一条insr
//与csr寄存器接口
output [`DECINFO_CSR_WIDTH-1:0]     csr_info_bus,
output [11:0]                       CSR_IDX,
input  [31:0]                       csr_data,
output                              csr_wb,     //csr寄存器写回使能信号
output                              mret_en,

input                               d_ITCM_r,    //因为LSU访问ITCM，需要暂停流水线
input                               d_ITCM

);                                                  

// To ID_Branch
wire                                dec_jal;
wire                                dec_jalr;
wire                                dec_bxx;  
wire [`ADDR_Bpu_WIDTH-1:0]          dec_bjp_imm;

wire [31:0]                         rv32_alu_imm;
wire [`DECINFO_BJP_WIDTH-1:0]       bjp_info_bus;
wire [`DECINFO_ALU_WIDTH-1:0]       alu_info_bus;


//div insr，保持该指令不变
//assign rv32_insr   = div_alu_time ? rv32_insr_mem_r
//                    : ((prdt_correct) ?  rv32_insr_mem : `ADDIR0);
assign rv32_insr   = (div_alu_time | ~d_hready) ? rv32_insr_mem_r 
                   : ((~i_hready) | d_ITCM | d_ITCM_r) ? `ADDIR0 : rv32_insr_mem;

assign rv32_rd     = rv32_insr[11:7];
assign rv32_rs1    = rv32_insr[19:15];
assign rv32_rs2    = rv32_insr[24:20];

wire [6:0] opcode                   = rv32_insr[6:0];
wire [2:0] rv32_func3               = rv32_insr[14:12];
wire [6:0] rv32_func7               = rv32_insr[31:25];

wire rv32_func3_000 = (rv32_func3 == 3'b000);
wire rv32_func3_001 = (rv32_func3 == 3'b001);
wire rv32_func3_010 = (rv32_func3 == 3'b010);
wire rv32_func3_011 = (rv32_func3 == 3'b011);
wire rv32_func3_100 = (rv32_func3 == 3'b100);
wire rv32_func3_101 = (rv32_func3 == 3'b101);
wire rv32_func3_110 = (rv32_func3 == 3'b110);
wire rv32_func3_111 = (rv32_func3 == 3'b111);

wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000); 
wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100); 
wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100); 
wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000); 
wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100); 
wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000); 
wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000); 
wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000); 
wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000); 
wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000); 
wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);  
wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);  
wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);  
wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001);  

wire [31:0] rv32_i_imm              = { {20{rv32_insr[31]}}
                                        , rv32_insr[31:20]};
//wire [31:0] rv32_shamt              = { {27{1'b0}}
//                                        , rv32_insr[24:20]};
wire [31:0] rv32_s_imm              = { {20{rv32_insr[31]}}
                                        , rv32_insr[31:25]
                                        , rv32_insr[11:7]};
wire [31:0] rv32_u_imm              = { rv32_insr[31:12], 12'b0};
wire [31:0] rv32_b_imm              = { {19{rv32_insr[31]}}
                                        , rv32_insr[31]
                                        , rv32_insr[7]
                                        , rv32_insr[30:25]
                                        , rv32_insr[11:8]
                                        , 1'b0};
wire [31:0] rv32_j_imm              = { {11{rv32_insr[31]}}
                                        , rv32_insr[31]
                                        , rv32_insr[19:12]
                                        , rv32_insr[20]
                                        , rv32_insr[30:21]
                                        , 1'b0};
//wire [31:0] rv32_z_imm              = {
//                                        {27{1'b0}}
//                                        , rv32_insr[19:15]};

wire rv32_bxx               = (opcode == 7'b1100011);
wire rv32_jalr              = (opcode == 7'b1100111);
wire rv32_jal               = (opcode == 7'b1101111);
wire rv32_R_M               = (opcode == 7'b0110011);
wire rv32_L                 = (opcode == 7'b0000011);
wire rv32_I_op              = (opcode == 7'b0010011);
wire rv32_S                 = (opcode == 7'b0100011);
wire rv32_auipc             = (opcode == 7'b0010111);
wire rv32_lui               = (opcode == 7'b0110111);
wire rv32_system            = (opcode == 7'b1110011);
wire rv32_fence_fencei      = (opcode == 7'b0001111);

assign dec_jal              =  rv32_jal ;
assign dec_jalr             =  rv32_jalr;
assign dec_bxx              =  rv32_bxx ;
//assign if_prdt              =  (|{stop_num, if_stop}) ? 1'b0 : (dec_jal | dec_jalr | dec_bxx);
// ===========================================================================
// Branch Instructions
wire rv32_beq               = rv32_bxx & rv32_func3_000;
wire rv32_bne               = rv32_bxx & rv32_func3_001;
wire rv32_blt               = rv32_bxx & rv32_func3_100;
wire rv32_bgt               = rv32_bxx & rv32_func3_101;
wire rv32_bltu              = rv32_bxx & rv32_func3_110;
wire rv32_bgtu              = rv32_bxx & rv32_func3_111;
wire rv32_fence             = rv32_fence_fencei & rv32_func3_000;
wire rv32_fence_i           = rv32_fence_fencei & rv32_func3_001;

//wire [`DECINFO_BJP_WIDTH-1:0] bjp_info_bus;
assign bjp_info_bus[`DECINFO_BJP_JUMP  ]        = rv32_jal | rv32_jalr;
assign bjp_info_bus[`DECINFO_BJP_BEQ   ]        = rv32_beq;
assign bjp_info_bus[`DECINFO_BJP_BNE   ]        = rv32_bne;
assign bjp_info_bus[`DECINFO_BJP_BLT   ]        = rv32_blt;
assign bjp_info_bus[`DECINFO_BJP_BGT   ]        = rv32_bgt;
assign bjp_info_bus[`DECINFO_BJP_BLTU  ]        = rv32_bltu;
assign bjp_info_bus[`DECINFO_BJP_BGTU  ]        = rv32_bgtu;
assign bjp_info_bus[`DECINFO_BJP_BXX   ]        = rv32_bxx;
assign bjp_info_bus[`DECINFO_BJP_FENCE ]        = rv32_fence;
assign bjp_info_bus[`DECINFO_BJP_FENCEI]        = rv32_fence_i;

// ===========================================================================
// System Instructions
wire rv32_ecall    = rv32_system & rv32_func3_000 & (rv32_insr[31:20] == 12'b0000_0000_0000);
wire rv32_ebreak   = rv32_system & rv32_func3_000 & (rv32_insr[31:20] == 12'b0000_0000_0001);
wire rv32_mret     = rv32_system & rv32_func3_000 & (rv32_insr[31:20] == 12'b0011_0000_0010);
//wire rv32_dret     = rv32_system & rv32_func3_000 & (rv32_insr[31:20] == 12'b0111_1011_0010);
//wire rv32_wfi      = rv32_system & rv32_func3_000 & (rv32_insr[31:20] == 12'b0001_0000_0101);
// We dont implement the WFI and MRET illegal exception when the rs and rd is not zeros
wire rv32_csrrw    = rv32_system & rv32_func3_001; 
wire rv32_csrrs    = rv32_system & rv32_func3_010; 
wire rv32_csrrc    = rv32_system & rv32_func3_011; 
wire rv32_csrrwi   = rv32_system & rv32_func3_101; 
wire rv32_csrrsi   = rv32_system & rv32_func3_110; 
wire rv32_csrrci   = rv32_system & rv32_func3_111; 

wire csr_op;     //表明该指令为csr指令
wire [4:0] csr_zimm = rv32_rs1;
wire csr_rs1_need  = rv32_csrrw | rv32_csrrs | rv32_csrrc;

assign CSR_IDX     = rv32_insr[31:20];
assign csr_op      = rv32_system & (~rv32_func3_000) & (~rv32_func3_100);
assign mret_en     = rv32_mret;

//wire rv32_ecall_ebreak  = rv32_system & rv32_func3_000;
//wire rv32_csr           = rv32_system & (~rv32_func3_000);

assign csr_info_bus[`DECINFO_CSR_CSRRW  ]       = rv32_csrrw | rv32_csrrwi;
assign csr_info_bus[`DECINFO_CSR_CSRRS  ]       = rv32_csrrs | rv32_csrrsi;
assign csr_info_bus[`DECINFO_CSR_CSRRC  ]       = rv32_csrrc | rv32_csrrci;

wire [31:0] csr_op1 = (rv32_csrrw | rv32_csrrs | rv32_csrrc) ? rs1_data : csr_zimm;
wire [31:0] csr_op2 = csr_data;

//csr寄存器写使能信号，CSRRS CSRRC，rs1索引值为0；CSRRSI CSRRCI，立即数值为0。不会发起写操作
assign csr_wb       = csr_op & (~((rv32_func3[2:1] == 2'b01) & (rv32_rs1 == 5'd0)))
                      & (~((rv32_func3[2:1] == 2'b11) & (csr_zimm == 5'd0)));
//--------------------------------------------------------------------------------
// ALU Insrctions
wire rv32_addi      = rv32_I_op & rv32_func3_000;
wire rv32_slti      = rv32_I_op & rv32_func3_010;
wire rv32_sltiu     = rv32_I_op & rv32_func3_011;
wire rv32_xori      = rv32_I_op & rv32_func3_100;
wire rv32_ori       = rv32_I_op & rv32_func3_110;
wire rv32_andi      = rv32_I_op & rv32_func3_111;

wire rv32_slli      = rv32_I_op & rv32_func3_001 & (rv32_insr[31:26] == 6'b000000);
wire rv32_srli      = rv32_I_op & rv32_func3_101 & (rv32_insr[31:26] == 6'b000000);
wire rv32_srai      = rv32_I_op & rv32_func3_101 & (rv32_insr[31:26] == 6'b010000);

assign dec_bjp_imm       =   ({32{rv32_bxx   }} & rv32_b_imm) 
                           | ({32{rv32_jalr  }} & rv32_i_imm)
                           | ({32{rv32_jal   }} & rv32_j_imm);


//wire sel_z_imm      = rv32_csrrwi | rv32_csrrsi | rv32_csrrci;
//wire sel_shamt      = rv32_slli | rv32_srli | rv32_srai;

assign rv32_alu_imm = (({32{rv32_I_op  | rv32_L  }} & rv32_i_imm)
                      | ({32{rv32_S               }} & rv32_s_imm) 
                      | ({32{rv32_auipc | rv32_lui}} & rv32_u_imm)
                      //| ({32{sel_z_imm            }} & rv32_z_imm)
                      //| ({32{sel_shamt            }} & rv32_shamt)
                      | ({32{rv32_jal | rv32_jalr }} & 32'd4     )
                      );   //rv32_jal | rv32_jalr需要写回寄存器，PC+4

//control signals
//assign RegWrite     = ((~rv32_S) & (~rv32_bxx) & (~rv32_fence_fencei) & (~rv32_ecall_ebreak)); 
assign RegWrite     = ((~rv32_S) & (~rv32_bxx) & (~rv32_fence_fencei) & (~rv32_system) & (~rv32_L)) | csr_op; //该信号不包括load写回
assign MemRead      = rv32_L;
assign MemWrite     = rv32_S;
assign RegWrite_all = ((~rv32_S) & (~rv32_bxx) & (~rv32_fence_fencei) & (~rv32_system)) | csr_op; //所有指令的写回控制信号
//wire rv32_sxxi_shamt_legl = (rv32_insr[25] == 1'b0); //shamt[5] must be zero for RV32I
// =  (rv32_slli | rv32_srli | rv32_srai) & (~rv32_sxxi_shamt_legl);

wire rv32_add      = rv32_R_M     & rv32_func3_000 & rv32_func7_0000000;
wire rv32_sub      = rv32_R_M     & rv32_func3_000 & rv32_func7_0100000;
wire rv32_sll      = rv32_R_M     & rv32_func3_001 & rv32_func7_0000000;
wire rv32_slt      = rv32_R_M     & rv32_func3_010 & rv32_func7_0000000;
wire rv32_sltu     = rv32_R_M     & rv32_func3_011 & rv32_func7_0000000;
wire rv32_xor      = rv32_R_M     & rv32_func3_100 & rv32_func7_0000000;
wire rv32_srl      = rv32_R_M     & rv32_func3_101 & rv32_func7_0000000;
wire rv32_sra      = rv32_R_M     & rv32_func3_101 & rv32_func7_0100000;
wire rv32_or       = rv32_R_M     & rv32_func3_110 & rv32_func7_0000000;
wire rv32_and      = rv32_R_M     & rv32_func3_111 & rv32_func7_0000000;

wire rv32_nop      = rv32_addi & (rv32_rs1 == 5'd0) & (rv32_rd == 5'd0) & (~(|rv32_insr[31:20]));

//wire [`DECINFO_ALU_WIDTH-1:0] alu_info_bus;
assign alu_info_bus[`DECINFO_ALU      ]         = |alu_info_bus[`DECINFO_ALU_WIDTH-1:1];
assign alu_info_bus[`DECINFO_ALU_ADD  ]         = rv32_add ;
assign alu_info_bus[`DECINFO_ALU_ADDI ]         = rv32_addi;
assign alu_info_bus[`DECINFO_ALU_SUB  ]         = rv32_sub;
assign alu_info_bus[`DECINFO_ALU_SLT  ]         = rv32_slt ;
assign alu_info_bus[`DECINFO_ALU_SLTU ]         = rv32_sltu;  
assign alu_info_bus[`DECINFO_ALU_SLTI ]         = rv32_slti;
assign alu_info_bus[`DECINFO_ALU_SLTIU]         = rv32_sltiu;
assign alu_info_bus[`DECINFO_ALU_XOR  ]         = rv32_xor ;
assign alu_info_bus[`DECINFO_ALU_XORI ]         = rv32_xori;
assign alu_info_bus[`DECINFO_ALU_SLL  ]         = rv32_sll ;
assign alu_info_bus[`DECINFO_ALU_SLLI ]         = rv32_slli;
assign alu_info_bus[`DECINFO_ALU_SRL  ]         = rv32_srl ;
assign alu_info_bus[`DECINFO_ALU_SRLI ]         = rv32_srli;
assign alu_info_bus[`DECINFO_ALU_SRA  ]         = rv32_sra ;
assign alu_info_bus[`DECINFO_ALU_SRAI ]         = rv32_srai;
assign alu_info_bus[`DECINFO_ALU_OR   ]         = rv32_or ;
assign alu_info_bus[`DECINFO_ALU_ORI  ]         = rv32_ori;
assign alu_info_bus[`DECINFO_ALU_AND  ]         = rv32_and ;
assign alu_info_bus[`DECINFO_ALU_ANDI ]         = rv32_andi;
assign alu_info_bus[`DECINFO_ALU_LUI  ]         = rv32_lui;
assign alu_info_bus[`DECINFO_ALU_auipc]         = rv32_auipc;
assign alu_info_bus[`DECINFO_ALU_NOP  ]         = rv32_nop;
assign alu_info_bus[`DECINFO_ALU_ECAL ]         = rv32_ecall;
assign alu_info_bus[`DECINFO_ALU_EBRK ]         = rv32_ebreak;

// ===========================================================================
// Load/Store Instructions
wire rv32_lb       = rv32_L   & rv32_func3_000;
wire rv32_lh       = rv32_L   & rv32_func3_001;
wire rv32_lw       = rv32_L   & rv32_func3_010;
wire rv32_lbu      = rv32_L   & rv32_func3_100;
wire rv32_lhu      = rv32_L   & rv32_func3_101;

wire rv32_sb       = rv32_S   & rv32_func3_000;
wire rv32_sh       = rv32_S   & rv32_func3_001;
wire rv32_sw       = rv32_S   & rv32_func3_010;

//wire [`DECINFO_L_S_WIDTH-1:0] mem_info_bus;
assign mem_info_bus[`DECINFO_LOAD_LB    ]       = rv32_lb;
assign mem_info_bus[`DECINFO_LOAD_LH    ]       = rv32_lh;
assign mem_info_bus[`DECINFO_LOAD_LW    ]       = rv32_lw;
assign mem_info_bus[`DECINFO_LOAD_LBU   ]       = rv32_lbu; 
assign mem_info_bus[`DECINFO_LOAD_LHU   ]       = rv32_lhu;
assign mem_info_bus[`DECINFO_Stor_SB    ]       = rv32_sb;
assign mem_info_bus[`DECINFO_Stor_SH    ]       = rv32_sh;
assign mem_info_bus[`DECINFO_Stor_SW    ]       = rv32_sw;
assign mem_info_bus[`DECINFO_L_S        ]       = |mem_info_bus[`DECINFO_Stor_SW_MSB:`DECINFO_LOAD_LB_LSB];

// ===========================================================================
// MUL/DIV Instructions
wire rv32_mul      = rv32_R_M     & rv32_func3_000 & rv32_func7_0000001;
wire rv32_mulh     = rv32_R_M     & rv32_func3_001 & rv32_func7_0000001;
wire rv32_mulhsu   = rv32_R_M     & rv32_func3_010 & rv32_func7_0000001;
wire rv32_mulhu    = rv32_R_M     & rv32_func3_011 & rv32_func7_0000001;
wire rv32_div      = rv32_R_M     & rv32_func3_100 & rv32_func7_0000001;
wire rv32_divu     = rv32_R_M     & rv32_func3_101 & rv32_func7_0000001;
wire rv32_rem      = rv32_R_M     & rv32_func3_110 & rv32_func7_0000001;
wire rv32_remu     = rv32_R_M     & rv32_func3_111 & rv32_func7_0000001;

//wire [`DECINFO_M_D_WIDTH-1:0] muldiv_info_bus;
assign muldiv_info_bus[`DECINFO_MD_MUL    ]     = rv32_mul;
assign muldiv_info_bus[`DECINFO_MD_MULH   ]     = rv32_mulh;
assign muldiv_info_bus[`DECINFO_MD_MULHU  ]     = rv32_mulhu;
assign muldiv_info_bus[`DECINFO_MD_MULHSU ]     = rv32_mulhsu;
//assign muldiv_info_bus[`DECINFO_MUL       ]     = |muldiv_info_bus[`DECINFO_MD_MULHSU_MSB:`DECINFO_MD_MUL_LSB]; rv32_R_M & rv32_func7_0000001 & (~rv32_func3[2]);
assign muldiv_info_bus[`DECINFO_MUL       ]     = rv32_R_M & rv32_func7_0000001 & (~rv32_func3[2]);
assign muldiv_info_bus[`DECINFO_MD_DIV    ]     = rv32_div;
assign muldiv_info_bus[`DECINFO_MD_DIVU   ]     = rv32_divu;
assign muldiv_info_bus[`DECINFO_MD_REM    ]     = rv32_rem;
assign muldiv_info_bus[`DECINFO_MD_REMU   ]     = rv32_remu;
//assign muldiv_info_bus[`DECINFO_DIV       ]     = |muldiv_info_bus[`DECINFO_MD_REMU_MSB:`DECINFO_MD_DIV_LSB];
assign muldiv_info_bus[`DECINFO_DIV       ]     = rv32_R_M & rv32_func7_0000001 & rv32_func3[2];
assign muldiv_info_bus[`DECINFO_MD        ]     = rv32_R_M & rv32_func7_0000001;

//数据冒险检测：是否rs1和rs2和上一指令rd相同
wire rs32_rs2_need  =   rv32_bxx | rv32_S | rv32_R_M;
wire rs32_rs1_need  =   rv32_bxx | rv32_S | rv32_R_M | rv32_I_op | rv32_L | rv32_jalr | csr_rs1_need;

//by stop_flag, test data hazrad
assign wr_stop1     =   ( (rs32_rs1_need & stop_flag[rv32_rs1]) | (rs32_rs2_need & stop_flag[rv32_rs2]) )
                        & (~div_alu_time) & d_hready;   // d_hready不能去掉，不然因为d_hready拉低，ID译码保持前一条指令
                                                        //导致前后周期译码指令相同，误触发wr_stop1拉高
//----------------------指令跳转-------------------------
assign if_Jump              =       (bjp_info_bus[`DECINFO_BJP_JUMP  ]) ? 1'b1 : 
                                  ( (bjp_info_bus[`DECINFO_BJP_BEQ   ] & (rs1_data == rs2_data)) 
                                  | (bjp_info_bus[`DECINFO_BJP_BNE   ] & (rs1_data != rs2_data))
                                  | (bjp_info_bus[`DECINFO_BJP_BLT   ] & ($signed(rs1_data) < $signed(rs2_data)))
                                  | (bjp_info_bus[`DECINFO_BJP_BGT   ] & ($signed(rs1_data) >= $signed(rs2_data)))
                                  | (bjp_info_bus[`DECINFO_BJP_BLTU  ] & ($unsigned(rs1_data) < $unsigned(rs2_data)))
                                  | (bjp_info_bus[`DECINFO_BJP_BGTU  ] & ($unsigned(rs1_data) >= $unsigned(rs2_data))) );
    
assign prdt_pc_add_op1      =    (dec_jal | dec_bxx) ? PC : rs1_data;
assign prdt_pc_add_op2      =    dec_bjp_imm;


//----------------------ALU类型及操作数译码-------------------------
assign Op_En[`add_en    ]   = alu_info_bus[`DECINFO_ALU_ADD  ] | alu_info_bus[`DECINFO_ALU_SUB  ] | alu_info_bus[`DECINFO_ALU_ADDI ]
                            | alu_info_bus[`DECINFO_ALU_auipc] | mem_info_bus[`DECINFO_L_S      ] | bjp_info_bus[`DECINFO_BJP_JUMP ];

assign Op_En[`com_en    ]   = alu_info_bus[`DECINFO_ALU_SLT  ] | alu_info_bus[`DECINFO_ALU_SLTU ] | alu_info_bus[`DECINFO_ALU_SLTI ] 
                            | alu_info_bus[`DECINFO_ALU_SLTIU];

assign Op_En[`com_sign  ]   = alu_info_bus[`DECINFO_ALU_SLT  ] | alu_info_bus[`DECINFO_ALU_SLTI ]; 

assign Op_En[`and_en    ]   = alu_info_bus[`DECINFO_ALU_AND  ] | alu_info_bus[`DECINFO_ALU_ANDI ];

assign Op_En[`or_en     ]   = alu_info_bus[`DECINFO_ALU_OR   ] | alu_info_bus[`DECINFO_ALU_ORI  ] | alu_info_bus[`DECINFO_ALU_LUI  ];

assign Op_En[`xor_en    ]   = alu_info_bus[`DECINFO_ALU_XOR  ] | alu_info_bus[`DECINFO_ALU_XORI ];

assign Op_En[`lgc_en    ]   = alu_info_bus[`DECINFO_ALU_SLL  ] | alu_info_bus[`DECINFO_ALU_SLLI ] | alu_info_bus[`DECINFO_ALU_SRL  ] 
                            | alu_info_bus[`DECINFO_ALU_SRLI ];

assign Op_En[`lgcl_en   ]   = alu_info_bus[`DECINFO_ALU_SLL  ] | alu_info_bus[`DECINFO_ALU_SLLI ];

assign Op_En[`alur_en   ]   = alu_info_bus[`DECINFO_ALU_SRA  ] | alu_info_bus[`DECINFO_ALU_SRAI ];

//----------------------ALU操作数控制-------------------------
wire    [`rv32_XLEN-1:0] ALUOp1;
wire    [`rv32_XLEN-1:0] ALUOp2;

//AUIPC指令，第一个操作数为PC，lui指令第一个操作数为0，其他指令第一个操作数为rs1_data    ,,增加csr操作数
assign ALUOp1               = (alu_info_bus[`DECINFO_ALU_auipc] | alu_info_bus[`DECINFO_ALU_LUI  ] | bjp_info_bus[`DECINFO_BJP_JUMP ]) ? 
                            ( {`rv32_XLEN{alu_info_bus[`DECINFO_ALU_auipc] | bjp_info_bus[`DECINFO_BJP_JUMP ]}} & PC ) : csr_op ? csr_op1 : rs1_data;

assign ALUOp2               = rv32_sub ? (~rs2_data) : ( rv32_I_op | rv32_lui | rv32_auipc | rv32_L | rv32_S | rv32_jal | rv32_jalr) ? rv32_alu_imm 
                            : csr_op ? csr_op2 : rs2_data;

assign Addcin               = rv32_sub;

//----------------------乘法操作数控制-------------------------
wire    [`rv32_XLEN-1:0] MULOp1;
wire    [`rv32_XLEN-1:0] MULOp2;

assign MULOp1               = ( (muldiv_info_bus[`DECINFO_MD_MULH] | muldiv_info_bus[`DECINFO_MD_MULHSU ]) & rs1_data[`rv32_XLEN-1] ) ? 
                            (~rs1_data + 1'b1) : rs1_data;
assign MULOp2               = (muldiv_info_bus[`DECINFO_MD_MULH   ] & rs2_data[`rv32_XLEN-1] )? (~rs2_data + 1'b1) : rs2_data;

assign MUL_sig              =   ( muldiv_info_bus[`DECINFO_MD_MULH] & (rs1_data[`rv32_XLEN-1] ^ rs2_data[`rv32_XLEN-1]) ) 
                              | ( muldiv_info_bus[`DECINFO_MD_MULHSU] & rs1_data[`rv32_XLEN-1] );

//----------------------除法操作数控制-------------------------
assign          DIVsign     =   muldiv_info_bus[`DECINFO_MD_DIV] | muldiv_info_bus[`DECINFO_MD_REM];

assign          a_opuns     =   muldiv_info_bus[`DECINFO_DIV] ? ((DIVsign & rs1_data[`rv32_XLEN-1]) ? $unsigned(~rs1_data + 1'b1) : rs1_data) : `rv32_XLEN'b0;   //根据输入符号位，将
assign          b_opuns     =   muldiv_info_bus[`DECINFO_DIV] ? ((DIVsign & rs2_data[`rv32_XLEN-1]) ? $unsigned(~rs2_data + 1'b1) : rs2_data) : `rv32_XLEN'b0;   //操作数转换为正数

//计算输入数据b最高位1的位置，第一层选择信号，第二层，第三层，第四层

wire    [5:0]   sel1_1,sel1_2,sel1_3,sel1_4,sel1_5,sel1_6,sel1_7,sel1_8;  
wire    [5:0]   sel1_9,sel1_10,sel1_11,sel1_12,sel1_13,sel1_14,sel1_15,sel1_16;
wire    [5:0]   sel2_1,sel2_2,sel2_3,sel2_4;
wire    [5:0]   sel2_5,sel2_6,sel2_7,sel2_8;
wire    [5:0]   sel3_1,sel3_2;
wire    [5:0]   sel3_3,sel3_4;
wire    [5:0]   sel4_1,sel4_2;

//第二层选择控制信号，第三层，第四层,5
wire            contral2_1, contral2_2, contral2_3, contral2_4;
wire            contral2_5, contral2_6, contral2_7, contral2_8;
wire            contral3_1, contral3_2;
wire            contral3_3, contral3_4;
wire            contral4_1, contral4_2;
wire            contral5_1;  

assign          sel1_1      =   b_opuns[31] ? 5'b0 : 6'b1;   
assign          sel1_2      =   b_opuns[29] ? 6'd2 : 6'd3;
assign          sel1_3      =   b_opuns[27] ? 6'd4 : 6'd5;
assign          sel1_4      =   b_opuns[25] ? 6'd6 : 6'd7;
assign          sel1_5      =   b_opuns[23] ? 6'd8 : 6'd9;
assign          sel1_6      =   b_opuns[21] ? 6'd10 : 6'd11;
assign          sel1_7      =   b_opuns[19] ? 6'd12 : 6'd13;
assign          sel1_8      =   b_opuns[17] ? 6'd14 : 6'd15;
assign          sel1_9      =   b_opuns[15] ? 6'd16 : 6'd17;
assign          sel1_10     =   b_opuns[13] ? 6'd18 : 6'd19;
assign          sel1_11     =   b_opuns[11] ? 6'd20 : 6'd21;
assign          sel1_12     =   b_opuns[09] ? 6'd22 : 6'd23;
assign          sel1_13     =   b_opuns[07] ? 6'd24 : 6'd25;
assign          sel1_14     =   b_opuns[05] ? 6'd26 : 6'd27;
assign          sel1_15     =   b_opuns[03] ? 6'd28 : 6'd29;
assign          sel1_16     =   b_opuns[01] ? 6'd30 : 6'd31;

assign          contral2_1  =   b_opuns[31] | b_opuns[30];
assign          contral2_2  =   b_opuns[27] | b_opuns[26];
assign          contral2_3  =   b_opuns[23] | b_opuns[22];
assign          contral2_4  =   b_opuns[19] | b_opuns[18];
assign          contral2_5  =   b_opuns[15] | b_opuns[14];
assign          contral2_6  =   b_opuns[11] | b_opuns[10];
assign          contral2_7  =   b_opuns[07] | b_opuns[06];
assign          contral2_8  =   b_opuns[03] | b_opuns[02];

assign          sel2_1      =   contral2_1 ? sel1_1 : sel1_2;
assign          sel2_2      =   contral2_2 ? sel1_3 : sel1_4;
assign          sel2_3      =   contral2_3 ? sel1_5 : sel1_6;
assign          sel2_4      =   contral2_4 ? sel1_7 : sel1_8;
assign          sel2_5      =   contral2_5 ? sel1_9 : sel1_10;
assign          sel2_6      =   contral2_6 ? sel1_11 : sel1_12;
assign          sel2_7      =   contral2_7 ? sel1_13 : sel1_14;
assign          sel2_8      =   contral2_8 ? sel1_15 : sel1_16;

assign          contral3_1  =   contral2_1 | b_opuns[29] | b_opuns[28];
assign          contral3_2  =   contral2_3 | b_opuns[21] | b_opuns[20];
assign          contral3_3  =   contral2_5 | b_opuns[13] | b_opuns[12];
assign          contral3_4  =   contral2_7 | b_opuns[05] | b_opuns[04];

assign          sel3_1      =   contral3_1 ? sel2_1 : sel2_2;
assign          sel3_2      =   contral3_2 ? sel2_3 : sel2_4;
assign          sel3_3      =   contral3_3 ? sel2_5 : sel2_6;
assign          sel3_4      =   contral3_4 ? sel2_7 : sel2_8;

assign          contral4_1  =   contral3_1 | contral2_2 | b_opuns[24] | b_opuns[25];
assign          contral4_2  =   contral3_3 | contral2_6 | b_opuns[8] | b_opuns[9];

assign          sel4_1      =   contral4_1 ? sel3_1 : sel3_2;
assign          sel4_2      =   contral4_2 ? sel3_3 : sel3_4;

assign          contral5_1  =   contral4_1 | contral3_2 | contral2_4 | b_opuns[17] | b_opuns[16];
assign          N2          =   contral5_1 ? sel4_1 : sel4_2;

//计算输入数据a最高位1的位置，第一层选择信号，第二层，第三层，第四层
wire    [5:0]   asel1_1,asel1_2,asel1_3,asel1_4,asel1_5,asel1_6,asel1_7,asel1_8;  
wire    [5:0]   asel1_9,asel1_10,asel1_11,asel1_12,asel1_13,asel1_14,asel1_15,asel1_16;
wire    [5:0]   asel2_1,asel2_2,asel2_3,asel2_4;
wire    [5:0]   asel2_5,asel2_6,asel2_7,asel2_8;
wire    [5:0]   asel3_1,asel3_2;
wire    [5:0]   asel3_3,asel3_4;
wire    [5:0]   asel4_1,asel4_2;

//第二层选择控制信号，第三层，第四层,5
wire            acontral2_1, acontral2_2, acontral2_3, acontral2_4;
wire            acontral2_5, acontral2_6, acontral2_7, acontral2_8;
wire            acontral3_1, acontral3_2;
wire            acontral3_3, acontral3_4;
wire            acontral4_1, acontral4_2;
wire            acontral5_1;  

assign          asel1_1      =   a_opuns[31] ? 6'b0 : 6'b1;   
assign          asel1_2      =   a_opuns[29] ? 6'd2 : 6'd3;
assign          asel1_3      =   a_opuns[27] ? 6'd4 : 6'd5;
assign          asel1_4      =   a_opuns[25] ? 6'd6 : 6'd7;
assign          asel1_5      =   a_opuns[23] ? 6'd8 : 6'd9;
assign          asel1_6      =   a_opuns[21] ? 6'd10 : 6'd11;
assign          asel1_7      =   a_opuns[19] ? 6'd12 : 6'd13;
assign          asel1_8      =   a_opuns[17] ? 6'd14 : 6'd15;
assign          asel1_9      =   a_opuns[15] ? 6'd16 : 6'd17;
assign          asel1_10     =   a_opuns[13] ? 6'd18 : 6'd19;
assign          asel1_11     =   a_opuns[11] ? 6'd20 : 6'd21;
assign          asel1_12     =   a_opuns[09] ? 6'd22 : 6'd23;
assign          asel1_13     =   a_opuns[07] ? 6'd24 : 6'd25;
assign          asel1_14     =   a_opuns[05] ? 6'd26 : 6'd27;
assign          asel1_15     =   a_opuns[03] ? 6'd28 : 6'd29;
assign          asel1_16     =   a_opuns[01] ? 6'd30 : 6'd31;


assign          acontral2_1 =   a_opuns[31] | a_opuns[30];
assign          acontral2_2 =   a_opuns[27] | a_opuns[26];
assign          acontral2_3 =   a_opuns[23] | a_opuns[22];
assign          acontral2_4 =   a_opuns[19] | a_opuns[18];
assign          acontral2_5 =   a_opuns[15] | a_opuns[14];
assign          acontral2_6 =   a_opuns[11] | a_opuns[10];
assign          acontral2_7 =   a_opuns[07] | a_opuns[06];
assign          acontral2_8 =   a_opuns[03] | a_opuns[02];

assign          asel2_1     =   acontral2_1 ? asel1_1 : asel1_2;
assign          asel2_2     =   acontral2_2 ? asel1_3 : asel1_4;
assign          asel2_3     =   acontral2_3 ? asel1_5 : asel1_6;
assign          asel2_4     =   acontral2_4 ? asel1_7 : asel1_8;
assign          asel2_5     =   acontral2_5 ? asel1_9 : asel1_10;
assign          asel2_6     =   acontral2_6 ? asel1_11 : asel1_12;
assign          asel2_7     =   acontral2_7 ? asel1_13 : asel1_14;
assign          asel2_8     =   acontral2_8 ? asel1_15 : asel1_16;

assign          acontral3_1 =   acontral2_1 | a_opuns[29] | a_opuns[28];
assign          acontral3_2 =   acontral2_3 | a_opuns[21] | a_opuns[20];
assign          acontral3_3 =   acontral2_5 | a_opuns[13] | a_opuns[12];
assign          acontral3_4 =   acontral2_7 | a_opuns[05] | a_opuns[04];

assign          asel3_1     =   acontral3_1 ? asel2_1 : asel2_2;
assign          asel3_2     =   acontral3_2 ? asel2_3 : asel2_4;
assign          asel3_3     =   acontral3_3 ? asel2_5 : asel2_6;
assign          asel3_4     =   acontral3_4 ? asel2_7 : asel2_8;

assign          acontral4_1 =   acontral3_1 | acontral2_2 | a_opuns[24] | a_opuns[25];
assign          acontral4_2 =   acontral3_3 | acontral2_6 | a_opuns[8] | a_opuns[9];

assign          asel4_1     =   acontral4_1 ? asel3_1 : asel3_2;
assign          asel4_2     =   acontral4_2 ? asel3_3 : asel3_4;

assign          acontral5_1 =   acontral4_1 | acontral3_2 | acontral2_4 | a_opuns[17] | a_opuns[16];
assign          N1          =   acontral5_1 ? asel4_1 : asel4_2;

//-------------------------操作数选择-------------------------
assign          Op1         =   muldiv_info_bus[`DECINFO_MUL] ? MULOp1 : ALUOp1;  //除法操作数包含在ALUop1、ALUop2中，即为rs1_data、rs2_data
assign          Op2         =   muldiv_info_bus[`DECINFO_MUL] ? MULOp2 : ALUOp2;

endmodule