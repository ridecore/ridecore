`include "constants.vh"
`default_nettype none
module sourceoperand_manager
  (
   input wire [`DATA_LEN-1:0]  arfdata,
   input wire 		       arf_busy,
   input wire 		       rrf_valid,
   input wire [`RRF_SEL-1:0]   rrftag,
   input wire [`DATA_LEN-1:0]  rrfdata,
   input wire [`RRF_SEL-1:0]   dst1_renamed,
   input wire 		       src_eq_dst1,
   input wire 		       src_eq_0,
   output wire [`DATA_LEN-1:0] src,
   output wire 		       rdy
   );

   assign src = src_eq_0 ? `DATA_LEN'b0 :
		src_eq_dst1 ? dst1_renamed :
		~arf_busy ? arfdata :
		rrf_valid ? rrfdata :
		rrftag;
   assign rdy = src_eq_0 | (~src_eq_dst1 & (~arf_busy | rrf_valid));

endmodule // sourceoperand_manager
`default_nettype wire
