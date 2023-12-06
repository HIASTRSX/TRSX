`include "risc_v_defines.vh"

module IF (
input                        clk,
input                        rst_n,

//ID_branch info
input                        if_Jump,
input  [`ADDR_Bpu_WIDTH-1:0] prdt_pc_add_op1,
input  [`ADDR_Bpu_WIDTH-1:0] prdt_pc_add_op2,
//output [`PC_WIDTH-1:0]       PC,
//output reg                   start,

output [`PC_WIDTH-1:0]       i_haddr,
output [3:0]                 i_hprot,
output [1:0]                 i_htrans,
output [2:0]                 i_hsize,
output [2:0]                 i_hburst,
input                        i_hready,
input  [1:0]                 i_hrespi,
output                       i_hsel,
//from EX下一clk，为低说明L/S指令在等待，保持PC当前�?
input                        d_hready,

input                        div_alu_time,
//data hazard, write flag
input                        wr_stop,

//中断接口
output [`PC_WIDTH-1:0]       normal_PC,
input                        trap_entry_en,
input                        trap_exit_en,
input  [`PC_WIDTH-1:0]       trap_entry_pc,
input  [`PC_WIDTH-1:0]       restore_pc,
//LS访问ITCM，需要暂停取�?
input                        d_ITCM,
input                        d_ITCM_r

);

wire [`PC_WIDTH-1:0] PC;    
reg  [`PC_WIDTH-1:0] PC_r;

reg                  start;
reg                  start_2;

wire [`PC_WIDTH-1:0] Add2PC_op2 = if_Jump ? prdt_pc_add_op2 : `PC_add_insr;
wire [`PC_WIDTH-1:0] Add2PC_op1 = if_Jump ? prdt_pc_add_op1 : PC_r;

//没有异常发生时，PC每次正常取�?�，包括顺序取指和跳转取�?
assign PC       = |{wr_stop, div_alu_time, ~i_hready, ~d_hready, d_ITCM | d_ITCM_r} ? PC_r : (start_2 ? (Add2PC_op1 + Add2PC_op2) 
                  : `ADDRESS_rst );

assign normal_PC= PC;

wire [`PC_WIDTH-1:0] PC_cur;
assign PC_cur   = trap_entry_en ? trap_entry_pc :
                  trap_exit_en  ? restore_pc 
                  : PC;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        PC_r                <= `ADDRESS_rst;
        start               <= 1'b0;
        start_2             <= 1'b0;
    end
    else begin
        PC_r                <= PC_cur;
        start               <= 1'b1;
        start_2             <= start;
    end
    
end

assign          i_haddr     = PC_cur;
assign          i_htrans    = start ? 2'b10 : 2'b00;
assign          i_hsize     = 3'b010;
assign          i_hburst    = 3'b000;
assign          i_hprot     = 4'b0011;
assign          i_hsel      = ~d_ITCM;

endmodule