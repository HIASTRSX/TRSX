`include "risc_v_defines.v"

module EX (

    input                                clk,
    input                                rst_n,

    input   [`DECINFO_M_D_WIDTH-1:0]     muldiv_info_bus,

    input   [`rv32_XLEN-1:0]             Op1,
    input   [`rv32_XLEN-1:0]             Op2,
    input                                Addcin,
    input                                MUL_sig,
    input   [`EN_Wid-1 : 0]              Op_En,
    input   [`rv32_XLEN:0]               a_opuns,
    input   [`rv32_XLEN:0]               b_opuns,
    input                                DIVsign,
    input   [5:0]                        N1,
    input   [5:0]                        N2,

    output  [`rv32_XLEN-1:0]             EX_res,
    output                               div_alu_time,
    output  [`rv32_XLEN-1:0]             addr_res,

    input   [`DECINFO_CSR_WIDTH-1:0]     csr_info_bus,

    input                                d_hready

);

//-----------------------------------ALU RESULT-----------------------------------
wire    [`rv32_XLEN-1:0] add_res;
wire    [`rv32_XLEN-1:0] add_op1;
wire    [`rv32_XLEN-1:0] add_op2;
wire                     add_cin;
assign add_op1              =   Op_En[`add_en] ? Op1 : `rv32_XLEN'b0;
assign add_op2              =   Op_En[`add_en] ? Op2 : `rv32_XLEN'b0;
assign add_cin              =   Op_En[`add_en] ? Addcin : 1'b0;
assign add_res              =   add_op1 + add_op2 + add_cin;

wire                     com_res;
wire    [`rv32_XLEN-1:0] com_op1;
wire    [`rv32_XLEN-1:0] com_op2;
assign com_op1              =   Op_En[`com_en] ? Op1 : `rv32_XLEN'b0;
assign com_op2              =   Op_En[`com_en] ? Op2 : `rv32_XLEN'b0;
assign com_res              =   Op_En[`com_sign] ? ($signed(Op1) < $signed(Op2)) : ($unsigned(Op1) < $unsigned(Op2)) ;

wire    [`rv32_XLEN-1:0] and_res;
wire    [`rv32_XLEN-1:0] and_op1;
wire    [`rv32_XLEN-1:0] and_op2;
assign and_op1              =   Op_En[`and_en] ? Op1 : `rv32_XLEN'b0;
assign and_op2              =   Op_En[`and_en] ? Op2 : `rv32_XLEN'b0;
assign and_res              =   and_op1 & and_op2;

wire    [`rv32_XLEN-1:0] or_res;
wire    [`rv32_XLEN-1:0] or_op1;
wire    [`rv32_XLEN-1:0] or_op2;
assign or_op1               =   Op_En[`or_en ] ? Op1 : `rv32_XLEN'b0;
assign or_op2               =   Op_En[`or_en ] ? Op2 : `rv32_XLEN'b0;
assign or_res               =   or_op1 | or_op2;

wire    [`rv32_XLEN-1:0] xor_res;
wire    [`rv32_XLEN-1:0] xor_op1;
wire    [`rv32_XLEN-1:0] xor_op2;
assign xor_op1              =   Op_En[`xor_en] ? Op1 : `rv32_XLEN'b0;
assign xor_op2              =   Op_En[`xor_en] ? Op2 : `rv32_XLEN'b0;
assign xor_res              =   xor_op1 ^ xor_op2;

//逻辑移位运算结果，如果是左移，则将op1反转后进行右移
wire    [`rv32_XLEN-1:0] lgc_res;
wire    [`rv32_XLEN-1:0] lgc_op1;
wire    [4:0]            lgc_op2;
wire    [`rv32_XLEN-1:0] lgc_op1_re;            //逻辑左移，将输入先反转，依旧进行右移操作
wire    [`rv32_XLEN-1:0] lgc_op;                //对lgc_op1和lgc_op1_re进行选择
wire    [`rv32_XLEN-1:0] lgc_res1;
wire    [`rv32_XLEN-1:0] lgc_res2;
wire    [`rv32_XLEN-1:0] lgc_res3;
wire    [`rv32_XLEN-1:0] lgc_res3_re;
assign lgc_op1              =   Op_En[`lgc_en] ? Op1 : `rv32_XLEN'b0;
assign lgc_op2              =   Op_En[`lgc_en] ? Op2[4:0] : `rv32_XLEN'b0;
assign lgc_op1_re           =   Op_En[`lgcl_en] ? { Op1[00],Op1[01],Op1[02],Op1[03],Op1[04],
                                                    Op1[05],Op1[06],Op1[07],Op1[08],Op1[09],
                                                    Op1[10],Op1[11],Op1[12],Op1[13],Op1[14],
                                                    Op1[15],Op1[16],Op1[17],Op1[18],Op1[19],
                                                    Op1[20],Op1[21],Op1[22],Op1[23],Op1[24],
                                                    Op1[25],Op1[26],Op1[27],Op1[28],Op1[29],
                                                    Op1[30],Op1[31] } : `rv32_XLEN'b0;
assign lgc_op               =   Op_En[`lgcl_en] ? lgc_op1_re : lgc_op1;
assign lgc_res1             =   ( {`rv32_XLEN{~(|lgc_op2[4:3])}} & lgc_op )
                              | ( {`rv32_XLEN{~lgc_op2[4] & lgc_op2[3]}} & {8'b0, lgc_op[31:8]} )
                              | ( {`rv32_XLEN{lgc_op2[4] & ~lgc_op2[3]}} & {16'b0, lgc_op[31:16]} )
                              | ( {`rv32_XLEN{&lgc_op2[4:3]}} & {24'b0, lgc_op[31:24]} );
assign lgc_res2             =   lgc_op2[2] ? {4'b0,lgc_res1[31:4]} : lgc_res1;
assign lgc_res3             =   ( {`rv32_XLEN{~(|lgc_op2[1:0])}} & lgc_res2 )     
                              | ( {`rv32_XLEN{~lgc_op2[1] & lgc_op2[0]}} & {1'b0, lgc_res2[31:1]} ) 
                              | ( {`rv32_XLEN{lgc_op2[1] & ~lgc_op2[0]}} & {2'b0, lgc_res2[31:2]} )
                              | ( {`rv32_XLEN{&lgc_op2[1:0]}} & {3'b0, lgc_res2[31:3]} );
assign lgc_res3_re          =   { lgc_res3[00],lgc_res3[01],lgc_res3[02],lgc_res3[03],lgc_res3[04],
                                  lgc_res3[05],lgc_res3[06],lgc_res3[07],lgc_res3[08],lgc_res3[09],
                                  lgc_res3[10],lgc_res3[11],lgc_res3[12],lgc_res3[13],lgc_res3[14],
                                  lgc_res3[15],lgc_res3[16],lgc_res3[17],lgc_res3[18],lgc_res3[19],
                                  lgc_res3[20],lgc_res3[21],lgc_res3[22],lgc_res3[23],lgc_res3[24],
                                  lgc_res3[25],lgc_res3[26],lgc_res3[27],lgc_res3[28],lgc_res3[29],
                                  lgc_res3[30],lgc_res3[31] };
assign lgc_res              =   Op_En[`lgcl_en] ? lgc_res3_re : lgc_res3;

//算术右移
wire    [`rv32_XLEN-1:0] alur_op1;
wire    [4:0]            alur_op2;
wire    [`rv32_XLEN-1:0] alur_res;
wire    [`rv32_XLEN-1:0] alur_res1;
wire    [`rv32_XLEN-1:0] alur_res2;
assign alur_op1             =   Op_En[`alur_en] ? Op1 : `rv32_XLEN'b0;
assign alur_op2             =   Op_En[`alur_en] ? Op2[4:0] : `rv32_XLEN'b0;
assign alur_res1            =   ( {`rv32_XLEN{~(|alur_op2[4:3])}} & alur_op1 )
                              | ( {`rv32_XLEN{(~alur_op2[4] & alur_op2[3])}} & {{8{alur_op1[31]}}, alur_op1[31:8]} )
                              | ( {`rv32_XLEN{alur_op2[4] & ~alur_op2[3]}} & {{16{alur_op1[31]}}, alur_op1[31:16]} )
                              | ( {`rv32_XLEN{&alur_op2[4:3]}} & {{24{alur_op1[31]}}, alur_op1[31:24]} );
assign alur_res2            =   alur_op2[2] ? {{4{alur_op1[31]}}, alur_res1[31:4]} : alur_res1;
assign alur_res             =   ( {`rv32_XLEN{~(|alur_op2[1:0])}} & alur_res2 )
                              | ( {`rv32_XLEN{~alur_op2[1] & alur_op2[0]}} & {alur_op1[31], alur_res2[31:1]} )
                              | ( {`rv32_XLEN{alur_op2[1] & ~alur_op2[0]}} & {{2{alur_op1[31]}}, alur_res2[31:2]} )
                              | ( {`rv32_XLEN{&alur_op2[1:0]}} & {{3{alur_op1[31]}}, alur_res2[31:3]} );   

wire    csr_en              = |csr_info_bus;
wire    [`rv32_XLEN-1:0] csr_res;
assign  csr_res             =   Op2;

wire    [`rv32_XLEN-1:0] ALU_res;
assign ALU_res              =   ({`rv32_XLEN{Op_En[`add_en]}} & add_res) | (Op_En[`com_en] & com_res) | ({`rv32_XLEN{Op_En[`and_en]}} & and_res)
                              | ({`rv32_XLEN{Op_En[`or_en ]}} & or_res ) | ({`rv32_XLEN{Op_En[`xor_en]}} & xor_res ) | ({`rv32_XLEN{Op_En[`lgc_en]}} & lgc_res )
                              | ({`rv32_XLEN{Op_En[`alur_en]}} & alur_res) | ({`rv32_XLEN{csr_en}} & csr_res);




//--------------------------------------mul result-----------------------------------
wire    [`rv32_XLEN-1:0] mul_op1;
wire    [`rv32_XLEN-1:0] mul_op2;
wire    [`rv32_XLEN-1:0] mul_res;
wire    [63:0]           mul_rd;
wire    [63:0]           mul_rd_sig;
//MUL_sig :0表示结果为正数、1表示负数
assign mul_op1              =   muldiv_info_bus[`DECINFO_MUL] ? Op1 : `rv32_XLEN'b0;
assign mul_op2              =   muldiv_info_bus[`DECINFO_MUL] ? Op2 : `rv32_XLEN'b0;
assign mul_rd               =   mul_op1 * mul_op2;
assign mul_rd_sig           =  ~mul_rd + 1'b1;
assign mul_res              =   muldiv_info_bus[`DECINFO_MD_MUL] ? mul_rd[31:0] : MUL_sig ? mul_rd_sig[63:32] : mul_rd[63:32];


//--------------------------------------div result-----------------------------------
wire                     div_en1;
wire                     outsel;         //选择输出结果是商还是余数，1表示结果为商
wire    [31:0]           quo;
wire    [31:0]           rem;
wire    [`rv32_XLEN-1:0] div_res;

//当d_hready为低时，说明L/S指令在等待数据
//此时流水线停顿，ID阶段停在下一条指令，为避免多次写入下一条指令，需要暂停EXen_wb
assign  div_en1             =   d_hready ? muldiv_info_bus[`DECINFO_DIV] : 1'b0;

assign  outsel              =   muldiv_info_bus[`DECINFO_MD_DIV] | muldiv_info_bus[`DECINFO_MD_DIVU];
assign  div_res             =   outsel ? quo : rem;
EX_DIV EX_DIV_u (
    .clk                     (clk),
    .rst_n                   (rst_n),
    .a                       (Op1),              //被除数
    .b                       (Op2),              //除数
    .sign                    (DIVsign),          //表示输入数是否为有符号数
    .div_en1                 (div_en1),               
    .quo_sign                (quo),
    .rem_sign                (rem),
    .alu_time                (div_alu_time),
    //finish                  (div_done)
    .a_opuns                 (a_opuns),
    .b_opuns                 (b_opuns),
    .N1                      (N1),
    .N2                      (N2)
);

assign EX_res               =    muldiv_info_bus[`DECINFO_MUL] ? mul_res : div_en1 ? div_res : ALU_res;
assign addr_res             =    add_res;

endmodule