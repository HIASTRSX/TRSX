module clk_gate_wrapper (
     i_clk   ,
     i_clk_en,
     o_gclk 
);
input   i_clk;
input   i_clk_en;
output  o_gclk;

assign  o_gclk = i_clk & i_clk_en;

endmodule 