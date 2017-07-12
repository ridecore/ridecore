`include "constants.vh"
`include "alu_ops.vh"
`default_nettype none
module rs_mul_ent
  (
   //Memory
   input wire 			 clk,
   input wire 			 reset,
   input wire 			 busy,
   input wire [`DATA_LEN-1:0] 	 wsrc1,
   input wire [`DATA_LEN-1:0] 	 wsrc2,
   input wire 			 wvalid1,
   input wire 			 wvalid2,
   input wire [`RRF_SEL-1:0] 	 wrrftag,
   input wire 			 wdstval,
   input wire [`SPECTAG_LEN-1:0] 	 wspectag,
   input wire 			 wsrc1_signed,
   input wire 			 wsrc2_signed,
   input wire 			 wsel_lohi,
   input wire 			 we,
   output wire [`DATA_LEN-1:0] 	 ex_src1,
   output wire [`DATA_LEN-1:0] 	 ex_src2,
   output wire 			 ready,
   output reg [`RRF_SEL-1:0] 	 rrftag,
   output reg 			 dstval,
   output reg [`SPECTAG_LEN-1:0] spectag,
   output reg 			 src1_signed,
   output reg 			 src2_signed,
   output reg 			 sel_lohi,
   //EXRSLT
   input wire [`DATA_LEN-1:0] 	 exrslt1,
   input wire [`RRF_SEL-1:0] 	 exdst1,
   input wire 			 kill_spec1,
   input wire [`DATA_LEN-1:0] 	 exrslt2,
   input wire [`RRF_SEL-1:0] 	 exdst2,
   input wire 			 kill_spec2,
   input wire [`DATA_LEN-1:0] 	 exrslt3,
   input wire [`RRF_SEL-1:0] 	 exdst3,
   input wire 			 kill_spec3,
   input wire [`DATA_LEN-1:0] 	 exrslt4,
   input wire [`RRF_SEL-1:0] 	 exdst4,
   input wire 			 kill_spec4,
   input wire [`DATA_LEN-1:0] 	 exrslt5,
   input wire [`RRF_SEL-1:0] 	 exdst5,
   input wire 			 kill_spec5
   );

   reg [`DATA_LEN-1:0] 		 src1;
   reg [`DATA_LEN-1:0] 		 src2;
   reg 				 valid1;
   reg 				 valid2;

   wire [`DATA_LEN-1:0] 	 nextsrc1;
   wire [`DATA_LEN-1:0] 	 nextsrc2;   
   wire 			 nextvalid1;
   wire 			 nextvalid2;
   
   assign ready = busy & valid1 & valid2;
   assign ex_src1 = ~valid1 & nextvalid1 ?
		    nextsrc1 : src1;
   assign ex_src2 = ~valid2 & nextvalid2 ?
		    nextsrc2 : src2;
   
   always @ (posedge clk) begin
      if (reset) begin
	 rrftag <= 0;
	 dstval <= 0;
	 spectag <= 0;
	 src1_signed <= 0;
	 src2_signed <= 0;
	 sel_lohi <= 0;

	 src1 <= 0;
	 src2 <= 0;
	 valid1 <= 0;
	 valid2 <= 0;
      end else if (we) begin
	 rrftag <= wrrftag;
	 dstval <= wdstval;
	 spectag <= wspectag;
	 src1_signed <= wsrc1_signed;
	 src2_signed <= wsrc2_signed;
	 sel_lohi <= wsel_lohi;

	 src1 <= wsrc1;
	 src2 <= wsrc2;
	 valid1 <= wvalid1;
	 valid2 <= wvalid2;
      end else begin // if (we)
	 src1 <= nextsrc1;
	 src2 <= nextsrc2;
	 valid1 <= nextvalid1;
	 valid2 <= nextvalid2;
      end
   end
   
   src_manager srcmng1(
		       .opr(src1),
		       .opr_rdy(valid1),
		       .exrslt1(exrslt1),
		       .exdst1(exdst1),
		       .kill_spec1(kill_spec1),
		       .exrslt2(exrslt2),
		       .exdst2(exdst2),
		       .kill_spec2(kill_spec2),
		       .exrslt3(exrslt3),
		       .exdst3(exdst3),
		       .kill_spec3(kill_spec3),
		       .exrslt4(exrslt4),
		       .exdst4(exdst4),
		       .kill_spec4(kill_spec4),
		       .exrslt5(exrslt5),
		       .exdst5(exdst5),
		       .kill_spec5(kill_spec5),
		       .src(nextsrc1),
		       .resolved(nextvalid1)
		       );

   src_manager srcmng2(
		       .opr(src2),
		       .opr_rdy(valid2),
		       .exrslt1(exrslt1),
		       .exdst1(exdst1),
		       .kill_spec1(kill_spec1),
		       .exrslt2(exrslt2),
		       .exdst2(exdst2),
		       .kill_spec2(kill_spec2),
		       .exrslt3(exrslt3),
		       .exdst3(exdst3),
		       .kill_spec3(kill_spec3),
		       .exrslt4(exrslt4),
		       .exdst4(exdst4),
		       .kill_spec4(kill_spec4),
		       .exrslt5(exrslt5),
		       .exdst5(exdst5),
		       .kill_spec5(kill_spec5),
		       .src(nextsrc2),
		       .resolved(nextvalid2)
		       );
   
endmodule // rs_mul


module rs_mul
  (
   //System
   input wire 			  clk,
   input wire 			  reset,
   output reg [`MUL_ENT_NUM-1:0]  busyvec,
   input wire 			  prmiss,
   input wire 			  prsuccess,
   input wire [`SPECTAG_LEN-1:0] 	  prtag,
   input wire [`SPECTAG_LEN-1:0] 	  specfixtag,
   //WriteSignal
   input wire 			  clearbusy, //Issue 
   input wire [`MUL_ENT_SEL-1:0] 	  issueaddr, //= raddr, clsbsyadr
   input wire 			  we1, //alloc1
   input wire 			  we2, //alloc2
   input wire [`MUL_ENT_SEL-1:0] 	  waddr1, //allocent1
   input wire [`MUL_ENT_SEL-1:0] 	  waddr2, //allocent2
   //WriteSignal1
   input wire [`DATA_LEN-1:0] 	  wsrc1_1,
   input wire [`DATA_LEN-1:0] 	  wsrc2_1,
   input wire 			  wvalid1_1,
   input wire 			  wvalid2_1,
   input wire [`RRF_SEL-1:0] 	  wrrftag_1,
   input wire 			  wdstval_1,
   input wire [`SPECTAG_LEN-1:0] 	  wspectag_1,
   input wire 			  wspecbit_1,
   input wire 			  wsrc1_signed_1,
   input wire 			  wsrc2_signed_1,
   input wire 			  wsel_lohi_1,

   //WriteSignal2
   input wire [`DATA_LEN-1:0] 	  wsrc1_2,
   input wire [`DATA_LEN-1:0] 	  wsrc2_2,
   input wire 			  wvalid1_2,
   input wire 			  wvalid2_2,
   input wire [`RRF_SEL-1:0] 	  wrrftag_2,
   input wire 			  wdstval_2,
   input wire [`SPECTAG_LEN-1:0] 	  wspectag_2,
   input wire 			  wspecbit_2,
   input wire 			  wsrc1_signed_2,
   input wire 			  wsrc2_signed_2,
   input wire 			  wsel_lohi_2,

   //ReadSignal
   output wire [`DATA_LEN-1:0] 	  ex_src1,
   output wire [`DATA_LEN-1:0] 	  ex_src2,
   output wire [`MUL_ENT_NUM-1:0] ready,
   output wire [`RRF_SEL-1:0] 	  rrftag,
   output wire 			  dstval,
   output wire [`SPECTAG_LEN-1:0] spectag,
   output wire 			  specbit,
   output wire 			  src1_signed,
   output wire 			  src2_signed,
   output wire 			  sel_lohi,

   //EXRSLT
   input wire [`DATA_LEN-1:0] 	  exrslt1,
   input wire [`RRF_SEL-1:0] 	  exdst1,
   input wire 			  kill_spec1,
   input wire [`DATA_LEN-1:0] 	  exrslt2,
   input wire [`RRF_SEL-1:0] 	  exdst2,
   input wire 			  kill_spec2,
   input wire [`DATA_LEN-1:0] 	  exrslt3,
   input wire [`RRF_SEL-1:0] 	  exdst3,
   input wire 			  kill_spec3,
   input wire [`DATA_LEN-1:0] 	  exrslt4,
   input wire [`RRF_SEL-1:0] 	  exdst4,
   input wire 			  kill_spec4,
   input wire [`DATA_LEN-1:0] 	  exrslt5,
   input wire [`RRF_SEL-1:0] 	  exdst5,
   input wire 			  kill_spec5
   );

   //_0
   wire [`DATA_LEN-1:0] 	      ex_src1_0;
   wire [`DATA_LEN-1:0] 	      ex_src2_0;
   wire 			      ready_0;
   wire [`RRF_SEL-1:0] 		      rrftag_0;
   wire 			      dstval_0;
   wire [`SPECTAG_LEN-1:0] 	      spectag_0;
   wire 			      src1_signed_0;
   wire 			      src2_signed_0;
   wire 			      sel_lohi_0;
   
   //_1
   wire [`DATA_LEN-1:0] 	      ex_src1_1;
   wire [`DATA_LEN-1:0] 	      ex_src2_1;
   wire 			      ready_1;
   wire [`RRF_SEL-1:0] 		      rrftag_1;
   wire 			      dstval_1;
   wire [`SPECTAG_LEN-1:0] 	      spectag_1;
   wire 			      src1_signed_1;
   wire 			      src2_signed_1;
   wire 			      sel_lohi_1;

   reg [`MUL_ENT_NUM-1:0] 	  specbitvec;

   wire [`MUL_ENT_NUM-1:0] 	  inv_vector =
				  {(spectag_1 & specfixtag) == 0 ? 1'b1 : 1'b0,
				   (spectag_0 & specfixtag) == 0 ? 1'b1 : 1'b0};

   wire [`MUL_ENT_NUM-1:0] 	  inv_vector_spec =
				  {(spectag_1 == prtag) ? 1'b0 : 1'b1,
				   (spectag_0 == prtag) ? 1'b0 : 1'b1};

   wire [`MUL_ENT_NUM-1:0] 	  specbitvec_next =
				  (inv_vector_spec & specbitvec);
   /* |
				  (we1 & wspecbit_1 ? (`MUL_ENT_SEL'b1 << waddr1) : 0) |
				  (we2 & wspecbit_2 ? (`MUL_ENT_SEL'b1 << waddr2) : 0);
    */
   assign specbit = prsuccess ? 
		    specbitvec_next[issueaddr] : specbitvec[issueaddr];

   assign ready = {ready_1, ready_0};
   
   always @ (posedge clk) begin
      if (reset) begin
	 busyvec <= 0;
	 specbitvec <= 0;
      end else begin
	 if (prmiss) begin
	    busyvec <= inv_vector & busyvec;
	    specbitvec <= 0;
	 end else if (prsuccess) begin
	    specbitvec <= specbitvec_next;
	    /*
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	    end
	     */
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end else begin
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	       specbitvec[waddr1] <= wspecbit_1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	       specbitvec[waddr2] <= wspecbit_2;
	    end
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end
      end
   end

   rs_mul_ent ent0(
		   .clk(clk),
		   .reset(reset),		      		   
		   .busy(busyvec[0]),
		   .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),
		   .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),
		   .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),
		   .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),
		   .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),
		   .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),
		   .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),
		   .wsrc1_signed((we1 && (waddr1 == 0)) ? wsrc1_signed_1 : wsrc1_signed_2),
		   .wsrc2_signed((we1 && (waddr1 == 0)) ? wsrc2_signed_1 : wsrc2_signed_2),
		   .wsel_lohi((we1 && (waddr1 == 0)) ? wsel_lohi_1 : wsel_lohi_2),
		   .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),
		   .ex_src1(ex_src1_0),
		   .ex_src2(ex_src2_0),
		   .ready(ready_0),
		   .rrftag(rrftag_0),
		   .dstval(dstval_0),
		   .spectag(spectag_0),
		   .src1_signed(src1_signed_0),
		   .src2_signed(src2_signed_0),
		   .sel_lohi(sel_lohi_0),
		   .exrslt1(exrslt1),
		   .exdst1(exdst1),
		   .kill_spec1(kill_spec1),
		   .exrslt2(exrslt2),
		   .exdst2(exdst2),
		   .kill_spec2(kill_spec2),
		   .exrslt3(exrslt3),
		   .exdst3(exdst3),
		   .kill_spec3(kill_spec3),
		   .exrslt4(exrslt4),
		   .exdst4(exdst4),
		   .kill_spec4(kill_spec4),
		   .exrslt5(exrslt5),
		   .exdst5(exdst5),
		   .kill_spec5(kill_spec5)
		   );

   rs_mul_ent ent1(
		   .clk(clk),
		   .reset(reset),		   
		   .busy(busyvec[1]),
		   .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),
		   .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),
		   .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),
		   .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),
		   .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),
		   .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),
		   .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),
		   .wsrc1_signed((we1 && (waddr1 == 1)) ? wsrc1_signed_1 : wsrc1_signed_2),
		   .wsrc2_signed((we1 && (waddr1 == 1)) ? wsrc2_signed_1 : wsrc2_signed_2),
		   .wsel_lohi((we1 && (waddr1 == 1)) ? wsel_lohi_1 : wsel_lohi_2),
		   .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),
		   .ex_src1(ex_src1_1),
		   .ex_src2(ex_src2_1),
		   .ready(ready_1),
		   .rrftag(rrftag_1),
		   .dstval(dstval_1),
		   .spectag(spectag_1),
		   .src1_signed(src1_signed_1),
		   .src2_signed(src2_signed_1),
		   .sel_lohi(sel_lohi_1),
		   .exrslt1(exrslt1),
		   .exdst1(exdst1),
		   .kill_spec1(kill_spec1),
		   .exrslt2(exrslt2),
		   .exdst2(exdst2),
		   .kill_spec2(kill_spec2),
		   .exrslt3(exrslt3),
		   .exdst3(exdst3),
		   .kill_spec3(kill_spec3),
		   .exrslt4(exrslt4),
		   .exdst4(exdst4),
		   .kill_spec4(kill_spec4),
		   .exrslt5(exrslt5),
		   .exdst5(exdst5),
		   .kill_spec5(kill_spec5)
		   );
   
   assign ex_src1 = (issueaddr == 0) ? ex_src1_0 : ex_src1_1;
   
   assign ex_src2 = (issueaddr == 0) ? ex_src2_0 : ex_src2_1;

   assign rrftag = (issueaddr == 0) ? rrftag_0 : rrftag_1;
   
   assign dstval = (issueaddr == 0) ? dstval_0 : dstval_1;

   assign spectag = (issueaddr == 0) ? spectag_0 : spectag_1;

   assign src1_signed = (issueaddr == 0) ? src1_signed_0 : src1_signed_1;

   assign src2_signed = (issueaddr == 0) ? src2_signed_0 : src2_signed_1;

   assign sel_lohi = (issueaddr == 0) ? sel_lohi_0 : sel_lohi_1;   
endmodule // rs_mul
`default_nettype wire
