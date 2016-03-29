`include "constants.vh"
`default_nettype none
module src_manager
  (
   input wire [`DATA_LEN-1:0]  opr,
   input wire 		       opr_rdy,
   input wire [`DATA_LEN-1:0]  exrslt1,
   input wire [`RRF_SEL-1:0]   exdst1,
   input wire 		       kill_spec1,
   input wire [`DATA_LEN-1:0]  exrslt2,
   input wire [`RRF_SEL-1:0]   exdst2,
   input wire 		       kill_spec2,
   input wire [`DATA_LEN-1:0]  exrslt3,
   input wire [`RRF_SEL-1:0]   exdst3,
   input wire 		       kill_spec3,
   input wire [`DATA_LEN-1:0]  exrslt4,
   input wire [`RRF_SEL-1:0]   exdst4,
   input wire 		       kill_spec4,
   input wire [`DATA_LEN-1:0]  exrslt5,
   input wire [`RRF_SEL-1:0]   exdst5,
   input wire 		       kill_spec5,
   output wire [`DATA_LEN-1:0] src,
   output wire 		       resolved
   );

   assign src = opr_rdy ? opr :
		~kill_spec1 & (exdst1 == opr) ? exrslt1 :
		~kill_spec2 & (exdst2 == opr) ? exrslt2 :
		~kill_spec3 & (exdst3 == opr) ? exrslt3 :
		~kill_spec4 & (exdst4 == opr) ? exrslt4 :
		~kill_spec5 & (exdst5 == opr) ? exrslt5 : opr;

   assign resolved = opr_rdy |
		     (~kill_spec1 & (exdst1 == opr)) |
		     (~kill_spec2 & (exdst2 == opr)) |
		     (~kill_spec3 & (exdst3 == opr)) |
		     (~kill_spec4 & (exdst4 == opr)) |
		     (~kill_spec5 & (exdst5 == opr));
   
endmodule // src_manager


`default_nettype wire
