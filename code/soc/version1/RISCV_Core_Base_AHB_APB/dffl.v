
module dffl #(parameter DW = 32)(
input  [DW-1:0] data_in,
input  ena,
output [DW-1:0] data_out,

input clk,
input rst_n
);

reg  [DW-1:0] data_out_r;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_out_r <= 'b0;
    end
    else if(ena) 
        data_out_r <= data_in;
    else
        data_out_r <= data_out_r;
end

assign data_out = data_out_r;

endmodule