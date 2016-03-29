`include "constants.vh"
`default_nettype none
module arf
  (
   input wire 			 clk,
   input wire 			 reset,
   input wire [`REG_SEL-1:0] 	 rs1_1, //DP from here
   input wire [`REG_SEL-1:0] 	 rs2_1,
   input wire [`REG_SEL-1:0] 	 rs1_2,
   input wire [`REG_SEL-1:0] 	 rs2_2,
   output wire [`DATA_LEN-1:0] 	 rs1_1data,
   output wire [`DATA_LEN-1:0] 	 rs2_1data,
   output wire [`DATA_LEN-1:0] 	 rs1_2data,
   output wire [`DATA_LEN-1:0] 	 rs2_2data, //DP end 
   input wire [`REG_SEL-1:0] 	 wreg1, //com_dst1
   input wire [`REG_SEL-1:0] 	 wreg2, //com_dst2
   input wire [`DATA_LEN-1:0] 	 wdata1, //com_data1
   input wire [`DATA_LEN-1:0] 	 wdata2, //com_data2
   input wire 			 we1, //com_en1
   input wire 			 we2, //com_en2
   input wire [`RRF_SEL-1:0] 	 wrrfent1, //comtag1
   input wire [`RRF_SEL-1:0] 	 wrrfent2, //comtag2
   output wire [`RRF_SEL-1:0] 	 rs1_1tag, // DP from here
   output wire [`RRF_SEL-1:0] 	 rs2_1tag,
   output wire [`RRF_SEL-1:0] 	 rs1_2tag,
   output wire [`RRF_SEL-1:0] 	 rs2_2tag,
   input wire [`REG_SEL-1:0] 	 tagbusy1_addr,
   input wire [`REG_SEL-1:0] 	 tagbusy2_addr,
   input wire 			 tagbusy1_we,
   input wire 			 tagbusy2_we,
   input wire [`RRF_SEL-1:0] 	 settag1,
   input wire [`RRF_SEL-1:0] 	 settag2,
   input wire [`SPECTAG_LEN-1:0] tagbusy1_spectag,
   input wire [`SPECTAG_LEN-1:0] tagbusy2_spectag,
   output wire 			 rs1_1busy,
   output wire 			 rs2_1busy,
   output wire 			 rs1_2busy,
   output wire 			 rs2_2busy,
   input wire 			 prmiss,
   input wire 			 prsuccess,
   input wire [`SPECTAG_LEN-1:0] prtag,
   input wire [`SPECTAG_LEN-1:0] mpft_valid1,
   input wire [`SPECTAG_LEN-1:0] mpft_valid2
   );

   // Set priority on instruction2 WriteBack
   // wrrfent = comtag
   wire [`RRF_SEL-1:0] 		 comreg1_tag;
   wire [`RRF_SEL-1:0] 		 comreg2_tag;
   wire 			 clearbusy1 = we1;
   wire 			 clearbusy2 = we2;

   wire 			 we1_0reg = we1 && 
				 (wreg1 != `REG_SEL'b0);
   
   wire 			 we2_0reg = we2 && 
				 (wreg2 != `REG_SEL'b0);
   
   wire 			 we1_prior2 = ((wreg1 == wreg2) &&
					       we1_0reg && we2_0reg) ? 
				 1'b0 : we1_0reg;
   
   // Set priority on instruction2 WriteBack
   // we when wrrfent1 == comreg1_tag
   ram_sync_nolatch_4r2w
     #(`REG_SEL, `DATA_LEN, `REG_NUM)
   regfile(
	   .clk(clk),
	   .raddr1(rs1_1),
	   .raddr2(rs2_1),
	   .raddr3(rs1_2),
	   .raddr4(rs2_2),
	   .rdata1(rs1_1data),
	   .rdata2(rs2_1data),
	   .rdata3(rs1_2data),
	   .rdata4(rs2_2data),
	   .waddr1(wreg1),
	   .waddr2(wreg2),
	   .wdata1(wdata1),
	   .wdata2(wdata2),
	   //	   .we1(we1_prior2),
	   .we1(we1_0reg),
	   .we2(we2_0reg)
	   );

   
   renaming_table rt(
		     .clk(clk),
		     .reset(reset),
		     .rs1_1(rs1_1),
		     .rs2_1(rs2_1),
		     .rs1_2(rs1_2),
		     .rs2_2(rs2_2),
		     .comreg1(wreg1),
		     .comreg2(wreg2),
		     .rs1_1tag(rs1_1tag),
		     .rs2_1tag(rs2_1tag),
		     .rs1_2tag(rs1_2tag),
		     .rs2_2tag(rs2_2tag),
		     .rs1_1busy(rs1_1busy),
		     .rs2_1busy(rs2_1busy),
		     .rs1_2busy(rs1_2busy),
		     .rs2_2busy(rs2_2busy),
		     .settagbusy1_addr(tagbusy1_addr),
		     .settagbusy2_addr(tagbusy2_addr),
		     .settagbusy1(tagbusy1_we),
		     .settagbusy2(tagbusy2_we),
		     .settag1(settag1),
		     .settag2(settag2),
		     .setbusy1_spectag(tagbusy1_spectag),
		     .setbusy2_spectag(tagbusy2_spectag),
		     .clearbusy1(clearbusy1),
		     .clearbusy2(clearbusy2),
		     .wrrfent1(wrrfent1),
		     .wrrfent2(wrrfent2),
		     .prmiss(prmiss),
		     .prsuccess(prsuccess),
		     .prtag(prtag),
		     .mpft_valid1(mpft_valid1),
		     .mpft_valid2(mpft_valid2)
		     );
   

endmodule // arf

// Set priority on instruction2 WriteBack
/*
 clear busy when comtag = rt_tag[comreg]
 */

module select_vector(
		     input wire [`SPECTAG_LEN-1:0] spectag,
		     input wire [`REG_NUM-1:0] 	   dat0,
		     input wire [`REG_NUM-1:0] 	   dat1,
		     input wire [`REG_NUM-1:0] 	   dat2,
		     input wire [`REG_NUM-1:0] 	   dat3,
		     input wire [`REG_NUM-1:0] 	   dat4,
		     output reg [`REG_NUM-1:0] 	   out
		     );

   always @ (*) begin
      out = 0;
      case (spectag)
	5'b00001 : out = dat1;
	5'b00010 : out = dat2;
	5'b00100 : out = dat3;
	5'b01000 : out = dat4;
	5'b10000 : out = dat0;
	default : out = 0;
      endcase // case (spectag) 
   end
endmodule // select_vector

module renaming_table
  (
   input wire 			 clk,
   input wire 			 reset,
   input wire [`REG_SEL-1:0] 	 rs1_1,
   input wire [`REG_SEL-1:0] 	 rs2_1,
   input wire [`REG_SEL-1:0] 	 rs1_2,
   input wire [`REG_SEL-1:0] 	 rs2_2,
   input wire [`REG_SEL-1:0] 	 comreg1, //clearbusy1addr
   input wire [`REG_SEL-1:0] 	 comreg2, //clearbusy2addr
   input wire 			 clearbusy1, //calc on arf
   input wire 			 clearbusy2,
   input wire [`RRF_SEL-1:0] 	 wrrfent1,
   input wire [`RRF_SEL-1:0] 	 wrrfent2, 
   output wire [`RRF_SEL-1:0] 	 rs1_1tag,
   output wire [`RRF_SEL-1:0] 	 rs2_1tag,
   output wire [`RRF_SEL-1:0] 	 rs1_2tag,
   output wire [`RRF_SEL-1:0] 	 rs2_2tag,
   output wire 			 rs1_1busy,
   output wire 			 rs2_1busy,
   output wire 			 rs1_2busy,
   output wire 			 rs2_2busy,
   input wire [`REG_SEL-1:0] 	 settagbusy1_addr,
   input wire [`REG_SEL-1:0] 	 settagbusy2_addr,
   input wire 			 settagbusy1,
   input wire 			 settagbusy2,
   input wire [`RRF_SEL-1:0] 	 settag1,
   input wire [`RRF_SEL-1:0] 	 settag2,
   input wire [`SPECTAG_LEN-1:0] setbusy1_spectag,
   input wire [`SPECTAG_LEN-1:0] setbusy2_spectag,

   input wire 			 prmiss,
   input wire 			 prsuccess,
   input wire [`SPECTAG_LEN-1:0] prtag,
   input wire [`SPECTAG_LEN-1:0] mpft_valid1,
   input wire [`SPECTAG_LEN-1:0] mpft_valid2
   );
   
   reg [`REG_NUM-1:0] 		 busy_0;
   reg [`REG_NUM-1:0] 		 tag0_0;
   reg [`REG_NUM-1:0] 		 tag1_0;
   reg [`REG_NUM-1:0] 		 tag2_0;
   reg [`REG_NUM-1:0] 		 tag3_0;
   reg [`REG_NUM-1:0] 		 tag4_0;
   reg [`REG_NUM-1:0] 		 tag5_0;
   
   reg [`REG_NUM-1:0] 		 busy_1;
   reg [`REG_NUM-1:0] 		 tag0_1;
   reg [`REG_NUM-1:0] 		 tag1_1;
   reg [`REG_NUM-1:0] 		 tag2_1;
   reg [`REG_NUM-1:0] 		 tag3_1;
   reg [`REG_NUM-1:0] 		 tag4_1;
   reg [`REG_NUM-1:0] 		 tag5_1;
   
   reg [`REG_NUM-1:0] 		 busy_2;
   reg [`REG_NUM-1:0] 		 tag0_2;
   reg [`REG_NUM-1:0] 		 tag1_2;
   reg [`REG_NUM-1:0] 		 tag2_2;
   reg [`REG_NUM-1:0] 		 tag3_2;
   reg [`REG_NUM-1:0] 		 tag4_2;
   reg [`REG_NUM-1:0] 		 tag5_2;
   
   reg [`REG_NUM-1:0] 		 busy_3;
   reg [`REG_NUM-1:0] 		 tag0_3;
   reg [`REG_NUM-1:0] 		 tag1_3;
   reg [`REG_NUM-1:0] 		 tag2_3;
   reg [`REG_NUM-1:0] 		 tag3_3;
   reg [`REG_NUM-1:0] 		 tag4_3;
   reg [`REG_NUM-1:0] 		 tag5_3;
   
   reg [`REG_NUM-1:0] 		 busy_4;
   reg [`REG_NUM-1:0] 		 tag0_4;
   reg [`REG_NUM-1:0] 		 tag1_4;
   reg [`REG_NUM-1:0] 		 tag2_4;
   reg [`REG_NUM-1:0] 		 tag3_4;
   reg [`REG_NUM-1:0] 		 tag4_4;
   reg [`REG_NUM-1:0] 		 tag5_4;
   
   reg [`REG_NUM-1:0] 		 busy_master;
   reg [`REG_NUM-1:0] 		 tag0_master;
   reg [`REG_NUM-1:0] 		 tag1_master;
   reg [`REG_NUM-1:0] 		 tag2_master;
   reg [`REG_NUM-1:0] 		 tag3_master;
   reg [`REG_NUM-1:0] 		 tag4_master;
   reg [`REG_NUM-1:0] 		 tag5_master;

   wire [`REG_NUM-1:0] 		 tag0;
   wire [`REG_NUM-1:0] 		 tag1;
   wire [`REG_NUM-1:0] 		 tag2;
   wire [`REG_NUM-1:0] 		 tag3;
   wire [`REG_NUM-1:0] 		 tag4;
   wire [`REG_NUM-1:0] 		 tag5;

   wire [`SPECTAG_LEN-1:0] 	 wesetvec1 = ~mpft_valid1;
   wire [`SPECTAG_LEN-1:0] 	 wesetvec2 = ~mpft_valid2;
   
   wire 			 settagbusy1_prior2 = settagbusy1 && settagbusy2 && 
				 (settagbusy1_addr == settagbusy2_addr) ? 1'b0 : settagbusy1;

   wire 			 clearbusy1_priorset = clearbusy1 && 
				 ~(
				   (settagbusy1 && (settagbusy1_addr == comreg1)) ||
				   (settagbusy2 && (settagbusy2_addr == comreg1))
				   );
   
   wire 			 clearbusy2_priorset = clearbusy2 &&
				 ~(
				   (settagbusy1 && (settagbusy1_addr == comreg2)) ||
				   (settagbusy2 && (settagbusy2_addr == comreg2))
				   );

   wire 			 setbusy1_master = settagbusy1_prior2;
   
   wire 			 setbusy2_master = settagbusy2;

   wire 			 clearbusy1_master = clearbusy1 &&  
				 (wrrfent1 == {tag5_master[comreg1], tag4_master[comreg1],
					       tag3_master[comreg1], tag2_master[comreg1], 
					       tag1_master[comreg1], tag0_master[comreg1]}) &&
				 ~((setbusy1_master && (settagbusy1_addr == comreg1)) ||
				   (setbusy2_master && (settagbusy2_addr == comreg1)));

   wire 			 clearbusy2_master = clearbusy2 &&  
				 (wrrfent2 == {tag5_master[comreg2], tag4_master[comreg2], 
					       tag3_master[comreg2], tag2_master[comreg2], 
					       tag1_master[comreg2], tag0_master[comreg2]}) &&
				 ~((setbusy1_master && (settagbusy1_addr == comreg2)) ||
				   (setbusy2_master && (settagbusy2_addr == comreg2)));

   
   wire 			 setbusy1_0 = settagbusy1_prior2 && wesetvec1[0];
   
   wire 			 setbusy2_0 = settagbusy2 && wesetvec2[0];

   wire 			 clearbusy1_0 = clearbusy1 &&  
				 (wrrfent1 == 
				  {tag5_0[comreg1], tag4_0[comreg1], tag3_0[comreg1],
				   tag2_0[comreg1], tag1_0[comreg1], tag0_0[comreg1]}) &&
				 ~((setbusy1_0 && (settagbusy1_addr == comreg1)) ||
				   (setbusy2_0 && (settagbusy2_addr == comreg1)));

   wire 			 clearbusy2_0 = clearbusy2 &&  
				 (wrrfent2 == 
				  {tag5_0[comreg2], tag4_0[comreg2], tag3_0[comreg2],
				   tag2_0[comreg2], tag1_0[comreg2], tag0_0[comreg2]}) &&
				 ~((setbusy1_0 && (settagbusy1_addr == comreg2)) ||
				   (setbusy2_0 && (settagbusy2_addr == comreg2)));

   wire 			 setbusy1_1 = settagbusy1_prior2 && wesetvec1[1];
   
   wire 			 setbusy2_1 = settagbusy2 && wesetvec2[1];

   wire 			 clearbusy1_1 = clearbusy1 &&  
				 (wrrfent1 == 
				  {tag5_1[comreg1], tag4_1[comreg1], tag3_1[comreg1],
				   tag2_1[comreg1], tag1_1[comreg1], tag0_1[comreg1]}) &&
				 ~((setbusy1_1 && (settagbusy1_addr == comreg1)) ||
				   (setbusy2_1 && (settagbusy2_addr == comreg1)));

   wire 			 clearbusy2_1 = clearbusy2 &&  
				 (wrrfent2 == 
				  {tag5_1[comreg2], tag4_1[comreg2], tag3_1[comreg2],
				   tag2_1[comreg2], tag1_1[comreg2], tag0_1[comreg2]}) &&
				 ~((setbusy1_1 && (settagbusy1_addr == comreg2)) ||
				   (setbusy2_1 && (settagbusy2_addr == comreg2)));

   wire 			 setbusy1_2 = settagbusy1_prior2 && wesetvec1[2];
   
   wire 			 setbusy2_2 = settagbusy2 && wesetvec2[2];

   wire 			 clearbusy1_2 = clearbusy1 &&  
				 (wrrfent1 == 
				  {tag5_2[comreg1], tag4_2[comreg1], tag3_2[comreg1],
				   tag2_2[comreg1], tag1_2[comreg1], tag0_2[comreg1]}) &&
				 ~((setbusy1_2 && (settagbusy1_addr == comreg1)) ||
				   (setbusy2_2 && (settagbusy2_addr == comreg1)));

   wire 			 clearbusy2_2 = clearbusy2 &&  
				 (wrrfent2 == 
				  {tag5_2[comreg2], tag4_2[comreg2], tag3_2[comreg2],
				   tag2_2[comreg2], tag1_2[comreg2], tag0_2[comreg2]}) &&
				 ~((setbusy1_2 && (settagbusy1_addr == comreg2)) ||
				   (setbusy2_2 && (settagbusy2_addr == comreg2)));

   wire 			 setbusy1_3 = settagbusy1_prior2 && wesetvec1[3];
   
   wire 			 setbusy2_3 = settagbusy2 && wesetvec2[3];

   wire 			 clearbusy1_3 = clearbusy1 &&  
				 (wrrfent1 == 
				  {tag5_3[comreg1], tag4_3[comreg1], tag3_3[comreg1],
				   tag2_3[comreg1], tag1_3[comreg1], tag0_3[comreg1]}) &&
				 ~((setbusy1_3 && (settagbusy1_addr == comreg1)) ||
				   (setbusy2_3 && (settagbusy2_addr == comreg1)));

   wire 			 clearbusy2_3 = clearbusy2 &&  
				 (wrrfent2 == 
				  {tag5_3[comreg2], tag4_3[comreg2], tag3_3[comreg2],
				   tag2_3[comreg2], tag1_3[comreg2], tag0_3[comreg2]}) &&
				 ~((setbusy1_3 && (settagbusy1_addr == comreg2)) ||
				   (setbusy2_3 && (settagbusy2_addr == comreg2)));

   wire 			 setbusy1_4 = settagbusy1_prior2 && wesetvec1[4];
   
   wire 			 setbusy2_4 = settagbusy2 && wesetvec2[4];

   wire 			 clearbusy1_4 = clearbusy1 &&  
				 (wrrfent1 == 
				  {tag5_4[comreg1], tag4_4[comreg1], tag3_4[comreg1],
				   tag2_4[comreg1], tag1_4[comreg1], tag0_4[comreg1]}) &&
				 ~((setbusy1_4 && (settagbusy1_addr == comreg1)) ||
				   (setbusy2_4 && (settagbusy2_addr == comreg1)));

   wire 			 clearbusy2_4 = clearbusy2 &&  
				 (wrrfent2 == 
				  {tag5_4[comreg2], tag4_4[comreg2], tag3_4[comreg2],
				   tag2_4[comreg2], tag1_4[comreg2], tag0_4[comreg2]}) &&
				 ~((setbusy1_4 && (settagbusy1_addr == comreg2)) ||
				   (setbusy2_4 && (settagbusy2_addr == comreg2)));

   wire [`REG_NUM-1:0] 		 next_bsymas = 
				 (busy_master &
				  ((clearbusy1_master) ? 
				   ~(`REG_NUM'b1 << comreg1) : 
				   ~(`REG_NUM'b0)) &
				  ((clearbusy2_master) ? 
				   ~(`REG_NUM'b1 << comreg2) : 
				   ~(`REG_NUM'b0))
				  );

   wire [`REG_NUM-1:0] 		 next_bsyand_0 =
				 ((clearbusy1_0) ? 
				  ~(`REG_NUM'b1 << comreg1) : 
				  ~(`REG_NUM'b0)) &
				 ((clearbusy2_0) ? 
				  ~(`REG_NUM'b1 << comreg2) : 
				  ~(`REG_NUM'b0));

   wire [`REG_NUM-1:0] 		 next_bsyand_1 =
				 ((clearbusy1_1) ? 
				  ~(`REG_NUM'b1 << comreg1) : 
				  ~(`REG_NUM'b0)) &
				 ((clearbusy2_1) ? 
				  ~(`REG_NUM'b1 << comreg2) : 
				  ~(`REG_NUM'b0));

   wire [`REG_NUM-1:0] 		 next_bsyand_2 =
				 ((clearbusy1_2) ? 
				  ~(`REG_NUM'b1 << comreg1) : 
				  ~(`REG_NUM'b0)) &
				 ((clearbusy2_2) ? 
				  ~(`REG_NUM'b1 << comreg2) : 
				  ~(`REG_NUM'b0));

   wire [`REG_NUM-1:0] 		 next_bsyand_3 =
				 ((clearbusy1_3) ? 
				  ~(`REG_NUM'b1 << comreg1) : 
				  ~(`REG_NUM'b0)) &
				 ((clearbusy2_3) ? 
				  ~(`REG_NUM'b1 << comreg2) : 
				  ~(`REG_NUM'b0));

   wire [`REG_NUM-1:0] 		 next_bsyand_4 =
				 ((clearbusy1_4) ? 
				  ~(`REG_NUM'b1 << comreg1) : 
				  ~(`REG_NUM'b0)) &
				 ((clearbusy2_4) ? 
				  ~(`REG_NUM'b1 << comreg2) : 
				  ~(`REG_NUM'b0));
   
   
   assign rs1_1busy = busy_master[rs1_1];
   assign rs2_1busy = busy_master[rs2_1];
   assign rs1_2busy = busy_master[rs1_2];
   assign rs2_2busy = busy_master[rs2_2];

   assign rs1_1tag = {tag5_master[rs1_1], tag4_master[rs1_1], tag3_master[rs1_1],
		      tag2_master[rs1_1], tag1_master[rs1_1], tag0_master[rs1_1]};
   assign rs2_1tag = {tag5_master[rs2_1], tag4_master[rs2_1], tag3_master[rs2_1],
		      tag2_master[rs2_1], tag1_master[rs2_1], tag0_master[rs2_1]};
   assign rs1_2tag = {tag5_master[rs1_2], tag4_master[rs1_2], tag3_master[rs1_2],
		      tag2_master[rs1_2], tag1_master[rs1_2], tag0_master[rs1_2]};
   assign rs2_2tag = {tag5_master[rs2_2], tag4_master[rs2_2], tag3_master[rs2_2],
		      tag2_master[rs2_2], tag1_master[rs2_2], tag0_master[rs2_2]};


   
   always @ (posedge clk) begin
      if (reset) begin
	 busy_0 <= 0;
	 busy_1 <= 0;
	 busy_2 <= 0;
	 busy_3 <= 0;
	 busy_4 <= 0;
	 busy_master <= 0;
      end else begin
	 if (prsuccess) begin
	    busy_master <= next_bsymas;
	    busy_1 <= (prtag == 5'b00010) ? next_bsymas : (next_bsyand_1 & busy_1);
	    busy_2 <= (prtag == 5'b00100) ? next_bsymas : (next_bsyand_2 & busy_2);
	    busy_3 <= (prtag == 5'b01000) ? next_bsymas : (next_bsyand_3 & busy_3);
	    busy_4 <= (prtag == 5'b10000) ? next_bsymas : (next_bsyand_4 & busy_4);
	    busy_0 <= (prtag == 5'b00001) ? next_bsymas : (next_bsyand_0 & busy_0);	    
	 end else if (prmiss) begin // if (prsuccess)
	    if (prtag == 5'b00010) begin
	       busy_0 <= busy_1;
	       busy_1 <= busy_1;
	       busy_2 <= busy_1;
	       busy_3 <= busy_1;
	       busy_4 <= busy_1;
	       busy_master <= busy_1;
	    end else if (prtag == 5'b00100) begin
	       busy_0 <= busy_2;
	       busy_1 <= busy_2;
	       busy_2 <= busy_2;
	       busy_3 <= busy_2;
	       busy_4 <= busy_2;
	       busy_master <= busy_2;
	    end else if (prtag == 5'b01000) begin
	       busy_0 <= busy_3;
	       busy_1 <= busy_3;
	       busy_2 <= busy_3;
	       busy_3 <= busy_3;
	       busy_4 <= busy_3;
	       busy_master <= busy_3;
	    end else if (prtag == 5'b10000) begin
	       busy_0 <= busy_4;
	       busy_1 <= busy_4;
	       busy_2 <= busy_4;
	       busy_3 <= busy_4;
	       busy_4 <= busy_4;
	       busy_master <= busy_4;
	    end else if (prtag == 5'b00001) begin
	       busy_0 <= busy_0;
	       busy_1 <= busy_0;
	       busy_2 <= busy_0;
	       busy_3 <= busy_0;
	       busy_4 <= busy_0;
	       busy_master <= busy_0;
	    end
	 end else begin // if (prmiss)
	    /*
	     if (setbusy1_j)
	     busy_j[settagbusy1_addr] <= 1'b1;
	     if (setbusy2_j)
	     busy_j[settagbusy2_addr] <= 1'b1;
	     if (clearbusy1_j)
	     busy_j[comreg1] <= 1'b0;
	     if (clearbusy2_j)
	     busy_j[comreg2] <= 1'b0;
	     */
	    if (setbusy1_master)
	      busy_master[settagbusy1_addr] <= 1'b1;
	    if (setbusy2_master)
	      busy_master[settagbusy2_addr] <= 1'b1;
	    if (clearbusy1_master)
	      busy_master[comreg1] <= 1'b0;
	    if (clearbusy2_master)
	      busy_master[comreg2] <= 1'b0;

	    if (setbusy1_0)
	      busy_0[settagbusy1_addr] <= 1'b1;
	    if (setbusy2_0)
	      busy_0[settagbusy2_addr] <= 1'b1;
	    if (clearbusy1_0)
	      busy_0[comreg1] <= 1'b0;
	    if (clearbusy2_0)
	      busy_0[comreg2] <= 1'b0;

	    if (setbusy1_1)
	      busy_1[settagbusy1_addr] <= 1'b1;
	    if (setbusy2_1)
	      busy_1[settagbusy2_addr] <= 1'b1;
	    if (clearbusy1_1)
	      busy_1[comreg1] <= 1'b0;
	    if (clearbusy2_1)
	      busy_1[comreg2] <= 1'b0;

	    if (setbusy1_2)
	      busy_2[settagbusy1_addr] <= 1'b1;
	    if (setbusy2_2)
	      busy_2[settagbusy2_addr] <= 1'b1;
	    if (clearbusy1_2)
	      busy_2[comreg1] <= 1'b0;
	    if (clearbusy2_2)
	      busy_2[comreg2] <= 1'b0;

	    if (setbusy1_3)
	      busy_3[settagbusy1_addr] <= 1'b1;
	    if (setbusy2_3)
	      busy_3[settagbusy2_addr] <= 1'b1;
	    if (clearbusy1_3)
	      busy_3[comreg1] <= 1'b0;
	    if (clearbusy2_3)
	      busy_3[comreg2] <= 1'b0;

	    if (setbusy1_4)
	      busy_4[settagbusy1_addr] <= 1'b1;
	    if (setbusy2_4)
	      busy_4[settagbusy2_addr] <= 1'b1;
	    if (clearbusy1_4)
	      busy_4[comreg1] <= 1'b0;
	    if (clearbusy2_4)
	      busy_4[comreg2] <= 1'b0;

	 end // else: !if(prmiss)
      end // else: !if(reset)
   end // always @ (posedge clk)

   always @ (posedge clk) begin
      if (reset) begin
	 tag0_0 <= 0;
	 tag1_0 <= 0;
	 tag2_0 <= 0;
	 tag3_0 <= 0;
	 tag4_0 <= 0;
	 tag5_0 <= 0;
	 tag0_1 <= 0;
	 tag1_1 <= 0;
	 tag2_1 <= 0;
	 tag3_1 <= 0;
	 tag4_1 <= 0;
	 tag5_1 <= 0;
	 tag0_2 <= 0;
	 tag1_2 <= 0;
	 tag2_2 <= 0;
	 tag3_2 <= 0;
	 tag4_2 <= 0;
	 tag5_2 <= 0;
	 tag0_3 <= 0;
	 tag1_3 <= 0;
	 tag2_3 <= 0;
	 tag3_3 <= 0;
	 tag4_3 <= 0;
	 tag5_3 <= 0;
	 tag0_4 <= 0;
	 tag1_4 <= 0;
	 tag2_4 <= 0;
	 tag3_4 <= 0;
	 tag4_4 <= 0;
	 tag5_4 <= 0;
	 tag0_master <= 0;
	 tag1_master <= 0;
	 tag2_master <= 0;
	 tag3_master <= 0;
	 tag4_master <= 0;
	 tag5_master <= 0;
      end else if (prsuccess) begin
	 tag0_master <= tag0_master;
	 tag1_master <= tag1_master;
	 tag2_master <= tag2_master;
	 tag3_master <= tag3_master;
	 tag4_master <= tag4_master;	 
	 tag5_master <= tag5_master;
	 
	 if (prtag == 5'b00010) begin
	    tag0_1 <= tag0_master;
	    tag1_1 <= tag1_master;
	    tag2_1 <= tag2_master;
	    tag3_1 <= tag3_master;
	    tag4_1 <= tag4_master;
	    tag5_1 <= tag5_master;
	 end else if (prtag == 5'b00100) begin
	    tag0_2 <= tag0_master;
	    tag1_2 <= tag1_master;
	    tag2_2 <= tag2_master;
	    tag3_2 <= tag3_master;
	    tag4_2 <= tag4_master;
	    tag5_2 <= tag5_master;
	 end else if (prtag == 5'b01000) begin
	    tag0_3 <= tag0_master;
	    tag1_3 <= tag1_master;
	    tag2_3 <= tag2_master;
	    tag3_3 <= tag3_master;
	    tag4_3 <= tag4_master;
	    tag5_3 <= tag5_master;
	 end else if (prtag == 5'b10000) begin
	    tag0_4 <= tag0_master;
	    tag1_4 <= tag1_master;
	    tag2_4 <= tag2_master;
	    tag3_4 <= tag3_master;
	    tag4_4 <= tag4_master;
	    tag5_4 <= tag5_master;
	 end else if (prtag == 5'b00001) begin
	    tag0_0 <= tag0_master;
	    tag1_0 <= tag1_master;
	    tag2_0 <= tag2_master;
	    tag3_0 <= tag3_master;
	    tag4_0 <= tag4_master;
	    tag5_0 <= tag5_master;
	 end
      end else if (prmiss) begin // if (prsuccess)
	 if (prtag == 5'b00010) begin
	    tag0_0 <= tag0_1;
	    tag1_0 <= tag1_1;
	    tag2_0 <= tag2_1;
	    tag3_0 <= tag3_1;
	    tag4_0 <= tag4_1;
	    tag5_0 <= tag5_1;
	    tag0_1 <= tag0_1;
	    tag1_1 <= tag1_1;
	    tag2_1 <= tag2_1;
	    tag3_1 <= tag3_1;
	    tag4_1 <= tag4_1;
	    tag5_1 <= tag5_1;
	    tag0_2 <= tag0_1;
	    tag1_2 <= tag1_1;
	    tag2_2 <= tag2_1;
	    tag3_2 <= tag3_1;
	    tag4_2 <= tag4_1;
	    tag5_2 <= tag5_1;
	    tag0_3 <= tag0_1;
	    tag1_3 <= tag1_1;
	    tag2_3 <= tag2_1;
	    tag3_3 <= tag3_1;
	    tag4_3 <= tag4_1;
	    tag5_3 <= tag5_1;
	    tag0_4 <= tag0_1;
	    tag1_4 <= tag1_1;
	    tag2_4 <= tag2_1;
	    tag3_4 <= tag3_1;
	    tag4_4 <= tag4_1;
	    tag5_4 <= tag5_1;
	    tag0_master <= tag0_1;
	    tag1_master <= tag1_1;
	    tag2_master <= tag2_1;
	    tag3_master <= tag3_1;
	    tag4_master <= tag4_1;
	    tag5_master <= tag5_1;
	 end else if (prtag == 5'b00100) begin
	    tag0_0 <= tag0_2;
	    tag1_0 <= tag1_2;
	    tag2_0 <= tag2_2;
	    tag3_0 <= tag3_2;
	    tag4_0 <= tag4_2;
	    tag5_0 <= tag5_2;
	    tag0_1 <= tag0_2;
	    tag1_1 <= tag1_2;
	    tag2_1 <= tag2_2;
	    tag3_1 <= tag3_2;
	    tag4_1 <= tag4_2;
	    tag5_1 <= tag5_2;
	    tag0_2 <= tag0_2;
	    tag1_2 <= tag1_2;
	    tag2_2 <= tag2_2;
	    tag3_2 <= tag3_2;
	    tag4_2 <= tag4_2;
	    tag5_2 <= tag5_2;
	    tag0_3 <= tag0_2;
	    tag1_3 <= tag1_2;
	    tag2_3 <= tag2_2;
	    tag3_3 <= tag3_2;
	    tag4_3 <= tag4_2;
	    tag5_3 <= tag5_2;
	    tag0_4 <= tag0_2;
	    tag1_4 <= tag1_2;
	    tag2_4 <= tag2_2;
	    tag3_4 <= tag3_2;
	    tag4_4 <= tag4_2;
	    tag5_4 <= tag5_2;
	    tag0_master <= tag0_2;
	    tag1_master <= tag1_2;
	    tag2_master <= tag2_2;
	    tag3_master <= tag3_2;
	    tag4_master <= tag4_2;
	    tag5_master <= tag5_2;
	 end else if (prtag == 5'b01000) begin
	    tag0_0 <= tag0_3;
	    tag1_0 <= tag1_3;
	    tag2_0 <= tag2_3;
	    tag3_0 <= tag3_3;
	    tag4_0 <= tag4_3;
	    tag5_0 <= tag5_3;
	    tag0_1 <= tag0_3;
	    tag1_1 <= tag1_3;
	    tag2_1 <= tag2_3;
	    tag3_1 <= tag3_3;
	    tag4_1 <= tag4_3;
	    tag5_1 <= tag5_3;
	    tag0_2 <= tag0_3;
	    tag1_2 <= tag1_3;
	    tag2_2 <= tag2_3;
	    tag3_2 <= tag3_3;
	    tag4_2 <= tag4_3;
	    tag5_2 <= tag5_3;
	    tag0_3 <= tag0_3;
	    tag1_3 <= tag1_3;
	    tag2_3 <= tag2_3;
	    tag3_3 <= tag3_3;
	    tag4_3 <= tag4_3;
	    tag5_3 <= tag5_3;
	    tag0_4 <= tag0_3;
	    tag1_4 <= tag1_3;
	    tag2_4 <= tag2_3;
	    tag3_4 <= tag3_3;
	    tag4_4 <= tag4_3;
	    tag5_4 <= tag5_3;
	    tag0_master <= tag0_3;
	    tag1_master <= tag1_3;
	    tag2_master <= tag2_3;
	    tag3_master <= tag3_3;
	    tag4_master <= tag4_3;
	    tag5_master <= tag5_3;
	 end else if (prtag == 5'b10000) begin
	    tag0_0 <= tag0_4;
	    tag1_0 <= tag1_4;
	    tag2_0 <= tag2_4;
	    tag3_0 <= tag3_4;
	    tag4_0 <= tag4_4;
	    tag5_0 <= tag5_4;
	    tag0_1 <= tag0_4;
	    tag1_1 <= tag1_4;
	    tag2_1 <= tag2_4;
	    tag3_1 <= tag3_4;
	    tag4_1 <= tag4_4;
	    tag5_1 <= tag5_4;
	    tag0_2 <= tag0_4;
	    tag1_2 <= tag1_4;
	    tag2_2 <= tag2_4;
	    tag3_2 <= tag3_4;
	    tag4_2 <= tag4_4;
	    tag5_2 <= tag5_4;
	    tag0_3 <= tag0_4;
	    tag1_3 <= tag1_4;
	    tag2_3 <= tag2_4;
	    tag3_3 <= tag3_4;
	    tag4_3 <= tag4_4;
	    tag5_3 <= tag5_4;
	    tag0_4 <= tag0_4;
	    tag1_4 <= tag1_4;
	    tag2_4 <= tag2_4;
	    tag3_4 <= tag3_4;
	    tag4_4 <= tag4_4;
	    tag5_4 <= tag5_4;
	    tag0_master <= tag0_4;
	    tag1_master <= tag1_4;
	    tag2_master <= tag2_4;
	    tag3_master <= tag3_4;
	    tag4_master <= tag4_4;
	    tag5_master <= tag5_4;
	 end else if (prtag == 5'b00001) begin
	    tag0_0 <= tag0_0;
	    tag1_0 <= tag1_0;
	    tag2_0 <= tag2_0;
	    tag3_0 <= tag3_0;
	    tag4_0 <= tag4_0;
	    tag5_0 <= tag5_0;
	    tag0_1 <= tag0_0;
	    tag1_1 <= tag1_0;
	    tag2_1 <= tag2_0;
	    tag3_1 <= tag3_0;
	    tag4_1 <= tag4_0;
	    tag5_1 <= tag5_0;
	    tag0_2 <= tag0_0;
	    tag1_2 <= tag1_0;
	    tag2_2 <= tag2_0;
	    tag3_2 <= tag3_0;
	    tag4_2 <= tag4_0;
	    tag5_2 <= tag5_0;
	    tag0_3 <= tag0_0;
	    tag1_3 <= tag1_0;
	    tag2_3 <= tag2_0;
	    tag3_3 <= tag3_0;
	    tag4_3 <= tag4_0;
	    tag5_3 <= tag5_0;
	    tag0_4 <= tag0_0;
	    tag1_4 <= tag1_0;
	    tag2_4 <= tag2_0;
	    tag3_4 <= tag3_0;
	    tag4_4 <= tag4_0;
	    tag5_4 <= tag5_0;
	    tag0_master <= tag0_0;
	    tag1_master <= tag1_0;
	    tag2_master <= tag2_0;
	    tag3_master <= tag3_0;
	    tag4_master <= tag4_0;
	    tag5_master <= tag5_0;
	 end 
      end else begin // if (prmiss)
	 if (settagbusy1) begin
	    //TAG0
	    tag0_master[settagbusy1_addr] <= settagbusy1_prior2 ?
					     settag1[0] : tag0_master[settagbusy1_addr];
	    
	    tag0_0[settagbusy1_addr] <= (wesetvec1[0] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[0] : tag0_0[settagbusy1_addr];
	    tag0_1[settagbusy1_addr] <= (wesetvec1[1] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[0] : tag0_1[settagbusy1_addr];
	    tag0_2[settagbusy1_addr] <= (wesetvec1[2] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[0] : tag0_2[settagbusy1_addr];
	    tag0_3[settagbusy1_addr] <= (wesetvec1[3] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[0] : tag0_3[settagbusy1_addr];
	    tag0_4[settagbusy1_addr] <= (wesetvec1[4] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[0] : tag0_4[settagbusy1_addr];
	    //TAG1
	    tag1_master[settagbusy1_addr] <= settagbusy1_prior2 ?
					     settag1[1] : tag1_master[settagbusy1_addr];
	    
	    tag1_0[settagbusy1_addr] <= (wesetvec1[0] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[1] : tag1_0[settagbusy1_addr];
	    tag1_1[settagbusy1_addr] <= (wesetvec1[1] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[1] : tag1_1[settagbusy1_addr];
	    tag1_2[settagbusy1_addr] <= (wesetvec1[2] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[1] : tag1_2[settagbusy1_addr];
	    tag1_3[settagbusy1_addr] <= (wesetvec1[3] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[1] : tag1_3[settagbusy1_addr];
	    tag1_4[settagbusy1_addr] <= (wesetvec1[4] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[1] : tag1_4[settagbusy1_addr];
	    //TAG2
	    tag2_master[settagbusy1_addr] <= settagbusy1_prior2 ?
					     settag1[2] : tag2_master[settagbusy1_addr];
	    tag2_0[settagbusy1_addr] <= (wesetvec1[0] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[2] : tag2_0[settagbusy1_addr];
	    tag2_1[settagbusy1_addr] <= (wesetvec1[1] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[2] : tag2_1[settagbusy1_addr];
	    tag2_2[settagbusy1_addr] <= (wesetvec1[2] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[2] : tag2_2[settagbusy1_addr];
	    tag2_3[settagbusy1_addr] <= (wesetvec1[3] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[2] : tag2_3[settagbusy1_addr];
	    tag2_4[settagbusy1_addr] <= (wesetvec1[4] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[2] : tag2_4[settagbusy1_addr];
	    //TAG3
	    tag3_master[settagbusy1_addr] <= settagbusy1_prior2 ?
					     settag1[3] : tag3_master[settagbusy1_addr];
	    tag3_0[settagbusy1_addr] <= (wesetvec1[0] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[3] : tag3_0[settagbusy1_addr];
	    tag3_1[settagbusy1_addr] <= (wesetvec1[1] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[3] : tag3_1[settagbusy1_addr];
	    tag3_2[settagbusy1_addr] <= (wesetvec1[2] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[3] : tag3_2[settagbusy1_addr];
	    tag3_3[settagbusy1_addr] <= (wesetvec1[3] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[3] : tag3_3[settagbusy1_addr];
	    tag3_4[settagbusy1_addr] <= (wesetvec1[4] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[3] : tag3_4[settagbusy1_addr];
	    //TAG4
	    tag4_master[settagbusy1_addr] <= settagbusy1_prior2 ?
					     settag1[4] : tag4_master[settagbusy1_addr];
	    tag4_0[settagbusy1_addr] <= (wesetvec1[0] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[4] : tag4_0[settagbusy1_addr];
	    tag4_1[settagbusy1_addr] <= (wesetvec1[1] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[4] : tag4_1[settagbusy1_addr];
	    tag4_2[settagbusy1_addr] <= (wesetvec1[2] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[4] : tag4_2[settagbusy1_addr];
	    tag4_3[settagbusy1_addr] <= (wesetvec1[3] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[4] : tag4_3[settagbusy1_addr];
	    tag4_4[settagbusy1_addr] <= (wesetvec1[4] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[4] : tag4_4[settagbusy1_addr];
	    //TAG5
	    tag5_master[settagbusy1_addr] <= settagbusy1_prior2 ?
					     settag1[5] : tag5_master[settagbusy1_addr];
	    tag5_0[settagbusy1_addr] <= (wesetvec1[0] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[5] : tag5_0[settagbusy1_addr];
	    tag5_1[settagbusy1_addr] <= (wesetvec1[1] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[5] : tag5_1[settagbusy1_addr];
	    tag5_2[settagbusy1_addr] <= (wesetvec1[2] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[5] : tag5_2[settagbusy1_addr];
	    tag5_3[settagbusy1_addr] <= (wesetvec1[3] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[5] : tag5_3[settagbusy1_addr];
	    tag5_4[settagbusy1_addr] <= (wesetvec1[4] & 
					 (settagbusy1_prior2 | 
					  (setbusy1_spectag != setbusy2_spectag))) ?
					settag1[5] : tag5_4[settagbusy1_addr];
	    
	 end // if (setttagbusy1)
	 if (settagbusy2) begin
	    //TAG0
	    tag0_master[settagbusy2_addr] <= settag2[0];
	    
	    tag0_0[settagbusy2_addr] <= wesetvec2[0] ? 
					settag2[0] : tag0_0[settagbusy2_addr];
	    tag0_1[settagbusy2_addr] <= wesetvec2[1] ? 
					settag2[0] : tag0_1[settagbusy2_addr];
	    tag0_2[settagbusy2_addr] <= wesetvec2[2] ? 
					settag2[0] : tag0_2[settagbusy2_addr];
	    tag0_3[settagbusy2_addr] <= wesetvec2[3] ? 
					settag2[0] : tag0_3[settagbusy2_addr];
	    tag0_4[settagbusy2_addr] <= wesetvec2[4] ? 
					settag2[0] : tag0_4[settagbusy2_addr];
	    //TAG1
	    tag1_master[settagbusy2_addr] <= settag2[1];
	    
	    tag1_0[settagbusy2_addr] <= wesetvec2[0] ? 
					settag2[1] : tag1_0[settagbusy2_addr];
	    tag1_1[settagbusy2_addr] <= wesetvec2[1] ? 
					settag2[1] : tag1_1[settagbusy2_addr];
	    tag1_2[settagbusy2_addr] <= wesetvec2[2] ? 
					settag2[1] : tag1_2[settagbusy2_addr];
	    tag1_3[settagbusy2_addr] <= wesetvec2[3] ? 
					settag2[1] : tag1_3[settagbusy2_addr];
	    tag1_4[settagbusy2_addr] <= wesetvec2[4] ? 
					settag2[1] : tag1_4[settagbusy2_addr];
	    //TAG2
	    tag2_master[settagbusy2_addr] <= settag2[2];
	    tag2_0[settagbusy2_addr] <= wesetvec2[0] ? 
					settag2[2] : tag2_0[settagbusy2_addr];
	    tag2_1[settagbusy2_addr] <= wesetvec2[1] ? 
					settag2[2] : tag2_1[settagbusy2_addr];
	    tag2_2[settagbusy2_addr] <= wesetvec2[2] ? 
					settag2[2] : tag2_2[settagbusy2_addr];
	    tag2_3[settagbusy2_addr] <= wesetvec2[3] ? 
					settag2[2] : tag2_3[settagbusy2_addr];
	    tag2_4[settagbusy2_addr] <= wesetvec2[4] ? 
					settag2[2] : tag2_4[settagbusy2_addr];
	    //TAG3
	    tag3_master[settagbusy2_addr] <= settag2[3];
	    tag3_0[settagbusy2_addr] <= wesetvec2[0] ? 
					settag2[3] : tag3_0[settagbusy2_addr];
	    tag3_1[settagbusy2_addr] <= wesetvec2[1] ? 
					settag2[3] : tag3_1[settagbusy2_addr];
	    tag3_2[settagbusy2_addr] <= wesetvec2[2] ? 
					settag2[3] : tag3_2[settagbusy2_addr];
	    tag3_3[settagbusy2_addr] <= wesetvec2[3] ? 
					settag2[3] : tag3_3[settagbusy2_addr];
	    tag3_4[settagbusy2_addr] <= wesetvec2[4] ? 
					settag2[3] : tag3_4[settagbusy2_addr];
	    //TAG4
	    tag4_master[settagbusy2_addr] <= settag2[4];
	    tag4_0[settagbusy2_addr] <= wesetvec2[0] ? 
					settag2[4] : tag4_0[settagbusy2_addr];
	    tag4_1[settagbusy2_addr] <= wesetvec2[1] ? 
					settag2[4] : tag4_1[settagbusy2_addr];
	    tag4_2[settagbusy2_addr] <= wesetvec2[2] ? 
					settag2[4] : tag4_2[settagbusy2_addr];
	    tag4_3[settagbusy2_addr] <= wesetvec2[3] ? 
					settag2[4] : tag4_3[settagbusy2_addr];
	    tag4_4[settagbusy2_addr] <= wesetvec2[4] ? 
					settag2[4] : tag4_4[settagbusy2_addr];
	    //TAG5
	    tag5_master[settagbusy2_addr] <= settag2[5];
	    tag5_0[settagbusy2_addr] <= wesetvec2[0] ? 
					settag2[5] : tag5_0[settagbusy2_addr];
	    tag5_1[settagbusy2_addr] <= wesetvec2[1] ? 
					settag2[5] : tag5_1[settagbusy2_addr];
	    tag5_2[settagbusy2_addr] <= wesetvec2[2] ? 
					settag2[5] : tag5_2[settagbusy2_addr];
	    tag5_3[settagbusy2_addr] <= wesetvec2[3] ? 
					settag2[5] : tag5_3[settagbusy2_addr];
	    tag5_4[settagbusy2_addr] <= wesetvec2[4] ? 
					settag2[5] : tag5_4[settagbusy2_addr];
	 end
      end
   end
endmodule // renaming_table
`default_nettype wire
