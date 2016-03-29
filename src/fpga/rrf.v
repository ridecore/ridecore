`include "constants.vh"

/*
 clear valid when dpen
 set valid when wrrfen
 */
`default_nettype none
module rrf(
	   input wire 		       clk,
	   input wire 		       reset,
	   input wire [`RRF_SEL-1:0]   rs1_1tag,
	   input wire [`RRF_SEL-1:0]   rs2_1tag,
	   input wire [`RRF_SEL-1:0]   rs1_2tag,
	   input wire [`RRF_SEL-1:0]   rs2_2tag,
	   input wire [`RRF_SEL-1:0]   com1tag,
	   input wire [`RRF_SEL-1:0]   com2tag,
	   output wire 		       rs1_1valid,
	   output wire 		       rs2_1valid,
	   output wire 		       rs1_2valid,
	   output wire 		       rs2_2valid,
	   output wire [`DATA_LEN-1:0] rs1_1data,
	   output wire [`DATA_LEN-1:0] rs2_1data,
	   output wire [`DATA_LEN-1:0] rs1_2data,
	   output wire [`DATA_LEN-1:0] rs2_2data,
	   output wire [`DATA_LEN-1:0] com1data,
	   output wire [`DATA_LEN-1:0] com2data,
	   input wire [`RRF_SEL-1:0]   wrrfaddr1,
	   input wire [`RRF_SEL-1:0]   wrrfaddr2,
	   input wire [`RRF_SEL-1:0]   wrrfaddr3,
	   input wire [`RRF_SEL-1:0]   wrrfaddr4,
	   input wire [`RRF_SEL-1:0]   wrrfaddr5,
	   input wire [`DATA_LEN-1:0]  wrrfdata1,
	   input wire [`DATA_LEN-1:0]  wrrfdata2,
	   input wire [`DATA_LEN-1:0]  wrrfdata3,
	   input wire [`DATA_LEN-1:0]  wrrfdata4,
	   input wire [`DATA_LEN-1:0]  wrrfdata5,
	   input wire 		       wrrfen1,
	   input wire 		       wrrfen2,
	   input wire 		       wrrfen3,
	   input wire 		       wrrfen4,
	   input wire 		       wrrfen5,
	   input wire [`RRF_SEL-1:0]   dpaddr1,
	   input wire [`RRF_SEL-1:0]   dpaddr2,
	   input wire 		       dpen1,
	   input wire 		       dpen2
	   );

   reg [`RRF_NUM-1:0] 		       valid;
   reg [`DATA_LEN-1:0] 		       datarr [0:`RRF_NUM-1];

   assign rs1_1data = datarr[rs1_1tag];
   assign rs2_1data = datarr[rs2_1tag];
   assign rs1_2data = datarr[rs1_2tag];
   assign rs2_2data = datarr[rs2_2tag];
   assign com1data = datarr[com1tag];
   assign com2data = datarr[com2tag];

   assign rs1_1valid = valid[rs1_1tag];
   assign rs2_1valid = valid[rs2_1tag];
   assign rs1_2valid = valid[rs1_2tag];
   assign rs2_2valid = valid[rs2_2tag];

   wire [`RRF_NUM-1:0] 		       or_valid = 
				       (~wrrfen1 ? `RRF_NUM'b0 : 
					(`RRF_NUM'b1 << wrrfaddr1)) |
				       (~wrrfen2 ? `RRF_NUM'b0 : 
					(`RRF_NUM'b1 << wrrfaddr2)) |
 				       (~wrrfen3 ? `RRF_NUM'b0 : 
					(`RRF_NUM'b1 << wrrfaddr3)) |
				       (~wrrfen4 ? `RRF_NUM'b0 : 
					(`RRF_NUM'b1 << wrrfaddr4)) |
				       (~wrrfen5 ? `RRF_NUM'b0 : 
					(`RRF_NUM'b1 << wrrfaddr5));
   
   wire [`RRF_NUM-1:0] 		       and_valid = 
				       (~dpen1 ? ~(`RRF_NUM'b0) : 
					~(`RRF_NUM'b1 << dpaddr1)) & 
				       (~dpen2 ? ~(`RRF_NUM'b0) : 
					~(`RRF_NUM'b1 << dpaddr2));

   always @ (posedge clk) begin
      if (reset) begin
	 valid <= 0;
      end else begin
	 valid <= (valid | or_valid) & and_valid;
      end
   end

   always @ (posedge clk) begin
      if (~reset) begin
	 if (wrrfen1)
	   datarr[wrrfaddr1] <= wrrfdata1;
	 if (wrrfen2)
	   datarr[wrrfaddr2] <= wrrfdata2;
	 if (wrrfen3)
	   datarr[wrrfaddr3] <= wrrfdata3;
	 if (wrrfen4)
	   datarr[wrrfaddr4] <= wrrfdata4;
	 if (wrrfen5)
	   datarr[wrrfaddr5] <= wrrfdata5;
      end
   end
endmodule // rrf
`default_nettype wire
