module EX_DIV #(
    parameter DW   = 32

) (
    clk,
    rst_n,
    a,                                  //被除数
    b,                                  //除数
    sign,                               //表示输入数是否为有符号数
    div_en1,                             //除法使能，每次一个时钟周期的脉冲信号
    quo_sign,
    rem_sign,
    alu_time,                            //除法运算过程中拉高，是流水线停顿

    a_opuns,
    b_opuns,
    N1,
    N2
);
input               clk;
input               rst_n;
input   [DW-1:0]    a;
input   [DW-1:0]    b;
input               div_en1;
input               sign;
output  [DW-1:0]    quo_sign;
output  [DW-1:0]    rem_sign;
output              alu_time;

input   [DW:0]      a_opuns; //输入数据a的绝对值
input   [DW:0]      b_opuns;
input   [5:0]       N1;         //a_opuns最高有效位1所在的位置
input   [5:0]       N2;

wire                div_en;         //检测每次除法开始的上升沿，表示除法开始运算，即op1取第一个数据a_op
wire                finish;

wire    [DW-1:0]    quo;
wire    [DW-1:0]    rem;

reg     [DW-1:0]    quo_r;

wire    [DW:0]  X;  //移位后的除数

reg     [DW:0]  X_reg;
reg     [DW:0]  Y_reg;

reg     [5:0]       count,count_2;                  //计数计算周期数目

wire    [5:0]       N2_1;
wire    [DW:0]      a_op, b_op;
wire    [5:0]       rem_N;          //rem需要移位数
wire    [DW-1:0]    rem_R;          //向右移位修正后的rem值
wire                res_sign;       //quo符号位
wire                remres_sign;    //rem符号位
wire                b_opuns1;       //b_opuns是否为1

wire                N1_2;           //N1>N2,表示a的绝对值小于b绝对值的一种子情况，这时直接出结果，不计算
wire                b_0;            //除数为0的情况
wire                overflow;       //溢出情况，输入仅为符号数时可能发生

//生成div_en信号
wire            div_en2;            //div_en2高电平区间表示在做除法运算，当完成一次运算（finish）
reg             div_en2_r;          //拉低div_en2，分隔开除法运算的间隔
assign          div_en2     =   finish ? 1'b0 : div_en1;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        div_en2_r <= 1'b0;
    end
    else begin
        div_en2_r <= div_en2;
    end
end
assign          div_en      =   div_en2 & (~div_en2_r);  //每次除法运算的上升沿，表示除法运算的第一个周期


assign          b_opuns1    =   (~(|b_opuns[DW:1])) & b_opuns[0];
assign          N1_2        =   N1 > N2;
assign          b_0         =   ~(|b);
//输入为有符号数，a = DW'b1000...0，表示-2^(XLEN-1)，b为-1,即DW'b11...111
assign          overflow    =   sign & (a[DW-1]) & (~(|a[DW-2:0])) & (&b[DW-1:0]);

 
assign          N2_1        =   N2 - N1; 
assign          rem_N       =   N1;

assign          a_op        =   a_opuns << N1;
assign          b_op        =   b_opuns << N2;
assign          res_sign    =   (sign & (a[DW-1]^b[DW-1])) ? 1'b1 : 1'b0;   //1表示商为负数、0表示商为正数
assign          remres_sign =   (sign & a[DW-1]) ? 1'b1 : 1'b0;

assign          X           =   div_en ? b_op : {1'b0, X_reg[DW:1]};
//wire            q           =   (Y_reg[DW]) ? 1'b0 : 1'b1;
wire            q           =    ~Y_reg[DW];

wire    [DW:0]  op1, op2, Y;

assign          op1         =   div_en ? a_op : Y_reg;
assign          op2         =   div_en ? (~b_op + 1'b1) 
                                : ((Y_reg[DW]) ? X : (~X + 1'b1));  
assign          Y           =   op1 + op2;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        count   <= 6'd0;
        X_reg   <= 'd0;
        Y_reg   <= 'd0;
        quo_r   <= 'd0;
   
        count_2 <= 6'd0;
    end
    else if(div_en & (~b_opuns1) & (~N1_2)) begin
        X_reg   <= X;
        Y_reg   <= Y;
        count   <= N2_1;
        count_2 <= N2_1 + 1'b1;

        quo_r   <= 'd0;
   
    end
    else begin
        if((|count[5:0])) begin
            Y_reg   <= Y;
            X_reg   <= X;
            count   <= count - 1'b1;
        end
        quo_r   <= quo;
  
        count_2 <= count;
    end
end


assign          finish      = (b_opuns1 | b_0 | overflow | N1_2) ? 1'b1 : (count_2 == 6'b1);
assign          quo         = b_opuns1 ? a_opuns : ((count | count_2) ? {quo_r[DW-2:0],q} : quo_r);
assign          rem         = (Y_reg[DW] ? (Y_reg + X_reg) : Y_reg);
assign          rem_R       = (b_opuns1 | N1_2) ? ({32{N1_2}} & a_opuns) : (rem >> rem_N);
//assign          quo_sign    = (b_0 | overflow | N1_2) ? ( ({32{(b_0 & sign)}}&(32'hFFFFFFFF)) 
//                            | ({32{((b_0 & ~sign)|overflow)}} & {1'b1,31'b0}) )
//                            : (res_sign ? (~quo + 1'b1) : quo);
assign          quo_sign    = (b_0 | overflow | N1_2) ? ( ({32{b_0}}&(32'hFFFFFFFF)) 
                            | ({32{overflow}} & {1'b1,31'b0}) )
                            : (res_sign ? (~quo + 1'b1) : quo);
assign          rem_sign    = (b_0 | overflow) ? ( b_0 ? a : 32'b0 ) 
                            : (remres_sign ? (~rem_R + 1'b1) : rem_R);

assign          alu_time    = |count[5:0] | div_en;



endmodule