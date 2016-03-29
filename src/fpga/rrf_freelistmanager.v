`include "constants.vh"
`default_nettype none
module rrf_freelistmanager
  (
   input wire 		      clk,
   input wire 		      reset,
   input wire 		      invalid1,
   input wire 		      invalid2,
   input wire [1:0] 	      comnum,
   input wire 		      prmiss,
   input wire [`RRF_SEL-1:0]  rrftagfix,
   output wire [`RRF_SEL-1:0] rename_dst1,
   output wire [`RRF_SEL-1:0] rename_dst2,
   output wire 		      allocatable,
   input wire 		      stall_DP, //= ~allocatable && ~prmiss
   output reg [`RRF_SEL:0]    freenum,
   output reg [`RRF_SEL-1:0]  rrfptr,
   input wire [`RRF_SEL-1:0]  comptr,
   output reg 		      nextrrfcyc
   );
   
   wire [1:0] 		      reqnum = {1'b0, ~invalid1} + {1'b0, ~invalid2};
   wire 		      hi = (comptr > rrftagfix) ? 1'b1 : 1'b0;
   wire [`RRF_SEL-1:0] 	      rrfptr_next = rrfptr + reqnum;
   
   assign allocatable = (freenum + comnum) < reqnum ? 1'b0 : 1'b1;
   assign rename_dst1 = rrfptr;
   assign rename_dst2 = rrfptr + (~invalid1 ? 1 : 0);
   
   always @ (posedge clk) begin
      if (reset) begin
	 freenum <= `RRF_NUM;
	 rrfptr <= 0;
	 nextrrfcyc <= 0;
      end else if (prmiss) begin
	 rrfptr <= rrftagfix; //== prmiss_rrftag+1
	 freenum <= `RRF_NUM - ({hi, rrftagfix} - {1'b0, comptr});
	 nextrrfcyc <= 0;
      end else if (stall_DP) begin
	 rrfptr <= rrfptr;
	 freenum <= freenum + comnum;
	 nextrrfcyc <= 0;
      end else begin
	 rrfptr <= rrfptr_next;
	 freenum <= freenum + comnum - reqnum;
	 nextrrfcyc <= (rrfptr > rrfptr_next) ? 1'b1 : 1'b0;
      end
   end
endmodule // rrf_freelistmanager


`default_nettype wire
