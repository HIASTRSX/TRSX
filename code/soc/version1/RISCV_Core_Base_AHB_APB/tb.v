`timescale 1ns/1ns
module tb(
);

reg clk, rst_n;
initial begin
    rst_n = 1'b0;
    clk = 1'b1;
    #101
    rst_n = 1'b1;
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
//integer coe;
  //reg [31:0] mem_test [0:511];
  initial 
  begin
    riscv_boot = $fopen("E:\\interrupt_test\\elf_dump\\os_planA_0.elf","rb");
    for(i=0;i<16384;i=i+1) begin
    	a = $fread(instr,riscv_boot);

    	if (a) begin
        	//SoC_u.ITCM.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
          SoC_u.SD.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
           	//SoC_u.DTCM.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
        end
      else begin
        //SoC_u.ITCM.BRAM[i] = 32'b0;
        SoC_u.SD.BRAM[i] = 32'b0;
        //SoC_u.DTCM.BRAM[i] = 32'b0;
      end
      SoC_u.DTCM.BRAM[i] = 32'b0;
    end  
    $fclose(riscv_boot);

	  riscv_boot = $fopen("E:\\interrupt_test\\elf_dump\\boot.elf","rb");
    for(i=0;i<4096;i=i+1) begin
    	a = $fread(instr,riscv_boot);

    	if (a) begin
        	SoC_u.ROM.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
           	//SoC_u.DTCM.BRAM[i] = {instr[7:0],instr[15:8],instr[23:16],instr[31:24]};
        end
        else begin
           SoC_u.ROM.BRAM[i] = 32'b0;
           //SoC_u.DTCM.BRAM[i] = 32'b0;
        end
    end  
    $fclose(riscv_boot);
    //$fclose(coe);
  end

endmodule