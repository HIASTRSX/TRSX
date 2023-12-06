`timescale 1ns/1ns
module tb(
);

reg clk, rst_n;
initial begin
    rst_n = 1'b0;
    clk = 1'b1;
    #101
    rst_n = 1'b1;
    //@(IF_ID_top_u.IF_u.PC == 32'h778) $stop;
end

always begin
    #10 clk = ~clk;
end

SoC SoC_u (
    .clk                (clk),
    .rst_n              (rst_n),

    .uart0_rx           (1'b0),
    .key1               (1'b1),
    .key2               (1'b1),
    .key3               (1'b1)
);

integer riscv_boot;
reg [31:0] instr;
integer i;
integer a;

//输出coe文件
integer coe;
  //reg [31:0] mem_test [0:511];
  initial 
  begin
    riscv_boot = $fopen("E:\\interrupt_test\\os15.elf","rb");
    coe        = $fopen("E:\\interrupt_test\\os15.coe","w");
    $fwrite(coe, "memory_initialization_radix = 16;\n");
    $fwrite(coe, "memory_initialization_vector =\n");
    $fflush(coe);
    for(i=0;i<16384;i=i+1) begin
      a = $fread(instr,riscv_boot);
      //if (i >= 1024) begin
         if (a) begin
           SoC_u.ITCM.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
           //SoC_u.DTCM.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
        end
        else begin
           SoC_u.ITCM.BRAM[i] = 32'b0;
           //SoC_u.DTCM.BRAM[i] = 32'b0;
        end
      //end
      if(i == 16383) begin
        $fwrite(coe, "%08h;", SoC_u.ITCM.BRAM[i]);
      end
      else begin
        $fwrite(coe, "%08h,\n", SoC_u.ITCM.BRAM[i]);
      end
      $fflush(coe);
    end  
    $fclose(riscv_boot);
    $fclose(coe);
  end

/*
`define Div_en      tb.IF_ID_top_u.EX_top2_u.EX_u.EX_DIV_u.div_en
`define Dividend    tb.IF_ID_top_u.EX_top2_u.EX_u.EX_DIV_u.a
`define Divisor     tb.IF_ID_top_u.EX_top2_u.EX_u.EX_DIV_u.b
reg     [31:0]      div_count = 32'd0;

integer DIV;
initial begin
  DIV = $fopen("E:\\risc_v_core\\test_insr\\DIV.txt","w");
end
always @(posedge clk) begin
  if(`Div_en) begin
    $fwrite(DIV, "Dividend: %08h  Divisor: %08h\n", `Dividend, `Divisor);
    $fflush(DIV);
    div_count <= div_count + 1'b1;
  end
end

*/
endmodule