module sd_to_ram (

    clk_ref,
    rst_n,
    rd_val_en,
    rd_val_data,
    rd_ram_data,
    addrB
);
input           clk_ref;
input           rst_n;
input           rd_val_en;          // write to ram, cs_wr
input  [15:0]   rd_val_data;        // write to ram, wdata
output [15:0]   rd_ram_data;
output [17:0]   addrB;

reg    [17:0]   addr_r;             // write to ram, addr
reg    [17:0]   addrb;              // read ram, addrb
wire   [17:0]   addr;

assign          addr = rd_val_en ? ( (addr_r == 18'd153599) ? 18'd0 : (addr_r + 1'b1) )
                       : addr_r;    // 680×480 = 307200, every point 16 bits 
                                    // 307200/2 = 153600, too large for bram test
assign          addrB= addrb;

always @(posedge clk_ref or negedge rst_n) begin
    if (~rst_n) begin
        addr_r <= 18'd0;
        addrb  <= 18'd0;
    end
    else begin
        addr_r <= addr;
        addrb  <= addrb + 1'b1;
        if (addrb == 18'd153599) addrb <= 18'd0;
    end
end 

blk_mem_gen_0 your_instance_name (
  .clka             (clk_ref),                  // input wire clka
  .wea              ({2{rd_val_en}}),           // input wire [1 : 0] wea
  .addra            (addr_r),                   // input wire [17 : 0] addra
  .dina             (rd_val_data),              // input wire [15 : 0] dina

  .clkb             (clk_ref),                  // input wire clkb
  .addrb            (addrb),                    // input wire [17 : 0] addrb
  .doutb            (rd_ram_data)               // output wire [15 : 0] doutb
);

endmodule