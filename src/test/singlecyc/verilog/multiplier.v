`include ""

module mux_4x1(
	       input [1:0] 	       sel,
	       input [2*`DATA_LEN-1:0] dat0,
	       input [2*`DATA_LEN-1:0] dat1,
	       input [2*`DATA_LEN-1:0] dat2,
	       input [2*`DATA_LEN-1:0] dat3,
	       output reg [2*`DATA_LEN-1:0] out
	       );
   always @(*) begin
      case(sel)
	0: begin
	   out = dat0;
	end
	1: begin
	   out = dat1;
	end
	2: begin
	   out = dat2;
	end
	3: begin
	   out = dat3;
	end
      endcase
   end
endmodule // mux_4x1

// sel_lohi = md_req_out_sel[0]
module multiplier(
		  input signed [`DATA_LEN-1:0] src1,
		  input signed [`DATA_LEN-1:0] src2,
		  input 		       src1_signed,
		  input 		       src2_signed,
		  input 		       sel_lohi,
		  output wire [`DATA_LEN-1:0]  result
		  );
/*
   wire 				      src1_neg = src1[`DATA_LEN-1] & src1_signed;
   wire 				      src2_neg = src2[`DATA_LEN-1] & src2_signed;
   wire [`DATA_LEN-1:0] 		      a = src1_neg ? -src1 : src1;
   wire [`DATA_LEN-1:0] 		      b = src2_neg ? -src2 : src2;
   wire [2*`DATA_LEN-1:0] 		      c = a * b;
   wire [2*`DATA_LEN-1:0] 		      c_signed = (src1_neg ^ src2_neg) ? c : -c;
  */
   wire signed [`DATA_LEN:0] 		      src1_unsign = {1'b0, src1};
   wire signed [`DATA_LEN:0] 		      src2_unsign = {1'b0, src2};

   wire signed [2*`DATA_LEN-1:0] 	      res_ss = src1 * src2;
   wire signed [2*`DATA_LEN-1:0] 	      res_su = src1 * src2_unsign;
   wire signed [2*`DATA_LEN-1:0] 	      res_us = src1_unsign * src2;
   wire signed [2*`DATA_LEN-1:0] 	      res_uu = src1_unsign * src2_unsign;

   wire [2*`DATA_LEN-1:0] 		      res;

   mux_4x1 mxres(
		.sel({src1_signed, src2_signed}),
		.dat0(res_uu),
		.dat1(res_us),
		.dat2(res_su),
		.dat3(res_ss),
		.out(res)
		);
      
   assign result = sel_lohi ? res[`DATA_LEN+:`DATA_LEN] : res[`DATA_LEN-1:0];
   
endmodule // multiplier

   
