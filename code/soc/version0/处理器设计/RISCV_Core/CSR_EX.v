`include "risc_v_defines.v"
module CSR_EX (

    input   [`DECINFO_CSR_WIDTH-1:0]     csr_info_bus,
    input   [`rv32_XLEN-1:0]             Op1,       //Op1 = rs1_data or zimm
    input   [`rv32_XLEN-1:0]             Op2,       //Op2 = csr_data 

    output  [`rv32_XLEN-1:0]             CSR_res
);

wire [`rv32_XLEN-1:0] CSRRW_res;
assign  CSRRW_res   = csr_info_bus[`DECINFO_CSR_CSRRW] ? Op1 : `rv32_XLEN'b0;

wire [`rv32_XLEN-1:0] CSRRS_res;
assign  CSRRS_res   = csr_info_bus[`DECINFO_CSR_CSRRS] ? (Op1 | Op2) : `rv32_XLEN'b0;

wire [`rv32_XLEN-1:0] CSRRC_res;
assign  CSRRC_res   = csr_info_bus[`DECINFO_CSR_CSRRC] ? (~Op1 & Op2) : `rv32_XLEN'b0;

assign  CSR_res     = CSRRW_res | CSRRS_res | CSRRC_res;
    
endmodule