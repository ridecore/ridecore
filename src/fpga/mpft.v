`include "constants.vh"
`default_nettype none
module tag_decoder
  (
   input wire [`SPECTAG_LEN-1:0] in,
   output reg [2:0] 		 out
   );

   always @ (*) begin
      out = 0;
      case (in)
	5'b00001: out = 0;
	5'b00010: out = 1;
	5'b00100: out = 2;
	5'b01000: out = 3;
	5'b10000: out = 4;
	default: out = 0;
      endcase // case (in)
   end
endmodule // tag_decoder

module miss_prediction_fix_table
  (
   input wire 			  clk,
   input wire 			  reset,
   output reg [`SPECTAG_LEN-1:0]  mpft_valid,
   input wire [`SPECTAG_LEN-1:0]  value_addr,
   output wire [`SPECTAG_LEN-1:0] mpft_value,
   input wire 			  prmiss,
   input wire 			  prsuccess,
   input wire [`SPECTAG_LEN-1:0]  prsuccess_tag,
   input wire [`SPECTAG_LEN-1:0]  setspec1_tag, //inst1_spectag
   input wire 			  setspec1_en, //inst1_isbranch & ~inst1_inv
   input wire [`SPECTAG_LEN-1:0]  setspec2_tag,
   input wire 			  setspec2_en
   );

   reg [`SPECTAG_LEN-1:0] 	  value0;
   reg [`SPECTAG_LEN-1:0] 	  value1;
   reg [`SPECTAG_LEN-1:0] 	  value2;
   reg [`SPECTAG_LEN-1:0] 	  value3;
   reg [`SPECTAG_LEN-1:0] 	  value4;

   wire [2:0] 			  val_idx;
   
   tag_decoder td(
		  .in(value_addr),
		  .out(val_idx)
		  );
   
   
   assign mpft_value = {
			value4[val_idx],
			value3[val_idx],
			value2[val_idx],
			value1[val_idx],
			value0[val_idx]
			};

   /*
    wire [`SPECTAG_LEN-1:0] value0_wdec =
    (~setspec1_tag[0] || ~setspec1_en ? 5'b0 :
    (setspec1_tag |
    ((setspec1_tag == 5'b00001) ? mpft_valid : 5'b0))) |
    (~setspec2_tag[0] || ~setspec2_en ? 5'b0 :
    (setspec2_tag |
    ((setspec2_tag == 5'b00001) ? mpft_valid : 5'b0)));
    */
   wire [`SPECTAG_LEN-1:0] 	  wdecdata = mpft_valid | (setspec1_en ? setspec1_tag : 0);

   wire [`SPECTAG_LEN-1:0] 	  value0_wdec =
				  (~setspec1_tag[0] || ~setspec1_en ? 5'b0 :
				   (setspec1_tag | 
				    ((setspec1_tag == 5'b00001) ? mpft_valid : 5'b0))) |
				  (~setspec2_tag[0] || ~setspec2_en ? 5'b0 :
				   (setspec2_tag |
				    ((setspec2_tag == 5'b00001) ? wdecdata : 5'b0)));
   
   wire [`SPECTAG_LEN-1:0] 	  value1_wdec =
				  (~setspec1_tag[1] || ~setspec1_en ? 5'b0 :
				   (setspec1_tag |
				    ((setspec1_tag == 5'b00010) ? mpft_valid : 5'b0))) |
				  (~setspec2_tag[1] || ~setspec2_en ? 5'b0 :
				   (setspec2_tag |
				    ((setspec2_tag == 5'b00010) ? wdecdata : 5'b0)));
   
   wire [`SPECTAG_LEN-1:0] 	  value2_wdec =
				  (~setspec1_tag[2] || ~setspec1_en ? 5'b0 :
				   (setspec1_tag |
				    ((setspec1_tag == 5'b00100) ? mpft_valid : 5'b0))) |
				  (~setspec2_tag[2] || ~setspec2_en ? 5'b0 :
				   (setspec2_tag |
				    ((setspec2_tag == 5'b00100) ? wdecdata : 5'b0)));
   
   wire [`SPECTAG_LEN-1:0] 	  value3_wdec =
				  (~setspec1_tag[3] || ~setspec1_en ? 5'b0 :
				   (setspec1_tag |
				    ((setspec1_tag == 5'b01000) ? mpft_valid : 5'b0))) |
				  (~setspec2_tag[3] || ~setspec2_en ? 5'b0 :
				   (setspec2_tag |
				    ((setspec2_tag == 5'b01000) ? wdecdata : 5'b0)));
   
   wire [`SPECTAG_LEN-1:0] 	  value4_wdec =
				  (~setspec1_tag[4] || ~setspec1_en ? 5'b0 :
				   (setspec1_tag |
				    ((setspec1_tag == 5'b10000) ? mpft_valid : 5'b0))) |
				  (~setspec2_tag[4] || ~setspec2_en ? 5'b0 :
				   (setspec2_tag |
				    ((setspec2_tag == 5'b10000) ? wdecdata : 5'b0)));
   
   wire [`SPECTAG_LEN-1:0] 	  value0_wprs =
				  (prsuccess_tag[0] ? 5'b0 : ~prsuccess_tag);
   wire [`SPECTAG_LEN-1:0] 	  value1_wprs =
				  (prsuccess_tag[1] ? 5'b0 : ~prsuccess_tag);
   wire [`SPECTAG_LEN-1:0] 	  value2_wprs =
				  (prsuccess_tag[2] ? 5'b0 : ~prsuccess_tag);
   wire [`SPECTAG_LEN-1:0] 	  value3_wprs =
				  (prsuccess_tag[3] ? 5'b0 : ~prsuccess_tag);
   wire [`SPECTAG_LEN-1:0] 	  value4_wprs =
				  (prsuccess_tag[4] ? 5'b0 : ~prsuccess_tag);
   
   always @ (posedge clk) begin
      if (reset | prmiss) begin
	 mpft_valid <= 0;
      end else if (prsuccess) begin
	 mpft_valid <= mpft_valid & ~prsuccess_tag;
      end else begin
	 mpft_valid <= mpft_valid | 
		       (setspec1_en ? setspec1_tag : 0) |
		       (setspec2_en ? setspec2_tag : 0);
      end
   end

   always @ (posedge clk) begin
      if (reset | prmiss) begin
	 value0 <= 0;
	 value1 <= 0;
	 value2 <= 0;
	 value3 <= 0;
	 value4 <= 0;
      end else begin
	 value0 <= prsuccess ? (value0 & value0_wprs) : (value0 | value0_wdec);
	 value1 <= prsuccess ? (value1 & value1_wprs) : (value1 | value1_wdec);
	 value2 <= prsuccess ? (value2 & value2_wprs) : (value2 | value2_wdec);
	 value3 <= prsuccess ? (value3 & value3_wprs) : (value3 | value3_wdec);
	 value4 <= prsuccess ? (value4 & value4_wprs) : (value4 | value4_wdec);
      end
   end
   
endmodule // miss_prediction_fix_table
`default_nettype wire
