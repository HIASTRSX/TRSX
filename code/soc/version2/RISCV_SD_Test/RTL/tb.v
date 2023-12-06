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

//-------------APB TEST signals--------------
//wire    [31:0]    haddr;
//wire     [1:0]    htrans;
//wire              hwrite;
//wire     [2:0]    hsize;
//wire     [2:0]    hburst;
//wire     [3:0]    hprot;
//wire    [31:0]    hwdata;
//wire    [31:0]    hrdata;
//wire              hready;

//reg     [31:0]    haddr_r;

SoC SoC_u (
    .clk                (clk),
    .rst_n              (rst_n),

    .uart0_rx           (1'b0),
    .key1               (1'b1),
    .key2               (1'b1),
    .key3               (1'b1)

    //--------------APB test---------------
    //.HADDRS             (haddr_r),
    //.HTRANSS            (htrans),
    //.HWRITES            (hwrite),
    //.HSIZES             (hsize),
    //.HWDATAS            (hwdata),
    //.HBURSTS            (hburst),
    //.HPROTS             (hprot),
    //.HREADYS            (hready),
    //.HRDATAS            (hrdata)
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
/*
reg             hwrite_r;
reg   [31:0]    hwdata_r;
reg             read;

assign          htrans    = 2'b10;
assign          hsize     = 3'b010;
assign          hburst    = 3'b000;
assign          hprot     = 4'b0011;
assign          hwrite    = hwrite_r;
assign          hwdata    = hwdata_r + 1'b1;
assign          haddr     = hready  ? (haddr_r + 3'd4) : haddr_r;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    haddr_r <= 32'h50001000;
    hwrite_r <= 1'b0;
    read    <= 1'b0;
  end
  else begin
    hwrite_r<= 1'b1;
    haddr_r <= haddr;
    if( haddr_r[15:0] == 16'h1190) begin
      read <= 1'b1;
      haddr_r <= 32'h50001000;
    end
    if(read) begin
      hwrite_r <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    hwdata_r <= 32'b0;
  end  
  else begin
    if(hwrite & hready) begin
      hwdata_r <= hwdata;
    end
  end
end
*/
endmodule