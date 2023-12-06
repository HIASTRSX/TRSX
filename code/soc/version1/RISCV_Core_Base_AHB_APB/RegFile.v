`include "risc_v_defines.vh"

module RegFile (

input   [`RF_IDX_WIDTH-1:0] rv32_rs1_idx,
input   [`RF_IDX_WIDTH-1:0] rv32_rs2_idx,
output  [`rv32_XLEN-1:0] read_rs1_data,
output  [`rv32_XLEN-1:0] read_rs2_data,

//wbck 写入EX执行结果数据
input   wbck_en,
input   [`RF_IDX_WIDTH-1:0] wbck_dest_idx,
input   [`rv32_XLEN-1:0] wbck_dest_data,

//wbck load指令，写入mem中数�?
input   Men_wb,
input   [`RF_IDX_WIDTH-1:0] Mrd_wb,
input   [`rv32_XLEN-1:0] Mdata_wb,

input   clk,
input   rst_n,

//from ID, to set write-flag
input   [`RF_IDX_WIDTH-1:0] rd,
input   RegWrite_all,
output  [`RF_REG_NUM-1:0] stop_flag,
input   wr_stop

);                     


reg  [`rv32_XLEN-1:0] rf_reg [`RF_REG_NUM-1:0];
wire [`rv32_XLEN-1:0] rf_reg_r [`RF_REG_NUM-1:0];
//reg  [`rv32_XLEN-1:0] rf_reg_r [`RF_REG_NUM-1:0];
//wire [`RF_REG_NUM-1:0] rf_wen;

reg  [`RF_REG_NUM-1:1] write_flag;
wire [`RF_REG_NUM-1:1] wr_flag;

genvar i;
generate
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rf_reg[2] <= 32'h20000;
        end
        else begin
            if(Men_wb & (Mrd_wb == 2)) begin
                rf_reg[2] <= Mdata_wb;
            end
            if(wbck_en & (wbck_dest_idx == 2)) begin
                rf_reg[2] <= wbck_dest_data;
            end                
        end
    end
    for(i=1; i < `RF_REG_NUM; i=i+1) begin:regFile
        if(i != 2) begin
            always @(posedge clk or negedge rst_n) begin
                if(~rst_n) begin
                    rf_reg[i] <= `rv32_XLEN'b0;
                end
                else begin
                    if(Men_wb & (Mrd_wb == i)) begin
                        rf_reg[i] <= Mdata_wb;
                    end
                    if(wbck_en & (wbck_dest_idx == i)) begin
                        rf_reg[i] <= wbck_dest_data;
                    end
                end
            end    
        end
        assign rf_reg_r[i] = rf_reg[i];
    end

endgenerate
//assign rf_wen[0] = 1'b0;
assign rf_reg_r[0] = `rv32_XLEN'b0;

genvar k;
generate

    for(k=1; k < `RF_REG_NUM; k=k+1) begin:Wrflag

        always @ (*) begin
            write_flag[k] = wr_flag[k];
            if( (wbck_en & (wbck_dest_idx == k)) | (Men_wb & (Mrd_wb == k)) ) begin
                write_flag[k] = 1'b0;
                if( RegWrite_all & (rd == k) & (~wr_stop) )          //如果下一条指令rd和这�?条rd相同，应该立即写�?
                    write_flag[k] = 1'b1;
            end
            //else if( RegWrite_all & (rd == k) & (~wr_flag[k]) )  // & wbck_en 
            else if( RegWrite_all & (rd == k) & (~wr_stop) )  // & wbck_en
                write_flag[k] = 1'b1;
        //    else 
        //        write_flag[k] = wr_flag[k];   �?要分别综合一下，看下实际电路，即将该赋�?�语�?
        end                                     //放在第一行以及最后else�?
        dffl #(.DW(1)) rf_dffl (write_flag[k], 1'b1, wr_flag[k], clk, rst_n);

        assign stop_flag[k] = ( (wbck_en & (wbck_dest_idx == k)) | (Men_wb & (Mrd_wb == k)) ) ? 1'b0 : wr_flag[k];
    end
endgenerate

assign  stop_flag[0]                    = 1'b0;

assign read_rs1_data = wbck_en & (rv32_rs1_idx == wbck_dest_idx) ? wbck_dest_data : (Men_wb & (rv32_rs1_idx == Mrd_wb)) ? Mdata_wb : rf_reg_r[rv32_rs1_idx];
assign read_rs2_data = wbck_en & (rv32_rs2_idx == wbck_dest_idx) ? wbck_dest_data : (Men_wb & (rv32_rs2_idx == Mrd_wb)) ? Mdata_wb : rf_reg_r[rv32_rs2_idx];


endmodule