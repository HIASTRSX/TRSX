
module pp_uart_baud(
            clk,
            rst,
            soft_rst,
            baud_div,
            baud_clk                
        );


input   clk;
input   rst;
input   soft_rst;
input   [13:0]baud_div;  
output  baud_clk;

reg   [9:0]clk_div;
reg   baud_clk;

reg [3:0] baud_cycle;
always @(posedge clk or negedge rst)
  if (~rst)
      baud_cycle <= 2'b0;
  else if(!soft_rst)
      baud_cycle <= 2'b0;
  else
      baud_cycle <= baud_cycle + baud_clk;
          
always @(posedge clk or negedge rst)
  if (~rst) 
    begin
      clk_div  <= 10'b0;
      baud_clk <= 1'b0; 
    end
  else if(!soft_rst) 
    begin
      clk_div  <= 10'b0;
      baud_clk <= 1'b0; 
    end
  else if (clk_div == baud_div[13:4]) 
    begin
      clk_div  <= (baud_cycle < baud_div[3:0]) ? 10'd0 : 10'd1;
      baud_clk <= 1'b1; 
    end 
  else 
    begin
      clk_div  <= clk_div + 1'b1;
      baud_clk <= 1'b0;
    end

endmodule
