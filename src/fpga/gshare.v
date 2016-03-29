`include "constants.vh"

/*
 ATTENTION!!!!!!!!!!!!!!!!!
 BHR in this code must change when spectag_len is changed
 */
`default_nettype none
module sel_bhrfix(
		  input wire [4:0] 		sel,
		  input wire [`GSH_BHR_LEN-1:0] bhr0,
		  input wire [`GSH_BHR_LEN-1:0] bhr1,
		  input wire [`GSH_BHR_LEN-1:0] bhr2,
		  input wire [`GSH_BHR_LEN-1:0] bhr3,
		  input wire [`GSH_BHR_LEN-1:0] bhr4,
		  output reg [`GSH_BHR_LEN-1:0] out
		  );
   always @ (*) begin
      out = 0;
      case (sel)
	5'b00001 : out = bhr0;
	5'b00010 : out = bhr1;
	5'b00100 : out = bhr2;
	5'b01000 : out = bhr3;
	5'b10000 : out = bhr4;
	default : out = 0;
      endcase // case (sel)
   end
   
endmodule // sel_bhr

//PRTAG is tag of prmiss/success branch instruction's
module gshare_predictor
  (
   input wire 			 clk,
   input wire 			 reset,
   input wire [`ADDR_LEN-1:0] 	 pc,
   input wire 			 hit_bht,
   output wire 			 predict_cond,
   input wire 			 we,
   input wire 			 wcond,
   input wire [`GSH_PHT_SEL-1:0] went,
   input wire [`SPECTAG_LEN-1:0] mpft_valid,
   input wire 			 prmiss,
   input wire 			 prsuccess,
   input wire [`SPECTAG_LEN-1:0] prtag,
   output reg [`GSH_BHR_LEN-1:0] bhr_master,
   input wire [`SPECTAG_LEN-1:0] spectagnow
   );

   reg [`GSH_BHR_LEN-1:0] 	 bhr0;
   reg [`GSH_BHR_LEN-1:0] 	 bhr1;
   reg [`GSH_BHR_LEN-1:0] 	 bhr2;
   reg [`GSH_BHR_LEN-1:0] 	 bhr3;
   reg [`GSH_BHR_LEN-1:0] 	 bhr4;
   wire [`GSH_BHR_LEN-1:0] 	 bhr_fix;
   wire [1:0] 			 rif;
   wire [1:0] 			 rex;
   wire [1:0] 			 wex;
   wire [2:0] 			 wex_calc;
   
   sel_bhrfix sb(
		 .sel(prtag),
		 .bhr0(bhr0),
		 .bhr1(bhr1),
		 .bhr2(bhr2),
		 .bhr3(bhr3),
		 .bhr4(bhr4),
		 .out(bhr_fix)
		 );
   
   always @ (posedge clk) begin
      if (reset) begin
	 bhr0 <= 0;
	 bhr1 <= 0;
	 bhr2 <= 0;
	 bhr3 <= 0;
	 bhr4 <= 0;
	 bhr_master <= 0;
      end else if (prmiss) begin
	 bhr0 <= bhr_fix;
	 bhr1 <= bhr_fix;
	 bhr2 <= bhr_fix;
	 bhr3 <= bhr_fix;
	 bhr4 <= bhr_fix;
	 bhr_master <= bhr_fix;
      end else if (prsuccess) begin
	 bhr0 <= (prtag == 5'b00001) ? {bhr_master[`GSH_BHR_LEN-2:0], predict_cond} : bhr0; 
	 bhr1 <= (prtag == 5'b00010) ? {bhr_master[`GSH_BHR_LEN-2:0], predict_cond} : bhr1;
	 bhr2 <= (prtag == 5'b00100) ? {bhr_master[`GSH_BHR_LEN-2:0], predict_cond} : bhr2;
	 bhr3 <= (prtag == 5'b01000) ? {bhr_master[`GSH_BHR_LEN-2:0], predict_cond} : bhr3;
	 bhr4 <= (prtag == 5'b10000) ? {bhr_master[`GSH_BHR_LEN-2:0], predict_cond} : bhr4;
      end else if (hit_bht) begin
	 if (we & mpft_valid[0]) begin
	    bhr0 <= {bhr0[`GSH_BHR_LEN-2:0], predict_cond};
	 end
	 if (we & mpft_valid[1]) begin
	    bhr1 <= {bhr1[`GSH_BHR_LEN-2:0], predict_cond};
	 end
	 if (we & mpft_valid[2]) begin
	    bhr2 <= {bhr2[`GSH_BHR_LEN-2:0], predict_cond};
	 end
	 if (we & mpft_valid[3]) begin
	    bhr3 <= {bhr3[`GSH_BHR_LEN-2:0], predict_cond};
	 end
	 if (we & mpft_valid[4]) begin
	    bhr4 <= {bhr4[`GSH_BHR_LEN-2:0], predict_cond};
	 end
	 if (we) begin
	    bhr_master <= {bhr_master[`GSH_BHR_LEN-2:0], predict_cond};
	 end
      end
   end
   
   assign predict_cond = (hit_bht && (rif > 2'b01)) ? 1'b1 : 1'b0;
   assign wex_calc = {1'b0, rex} + (wcond ? 3'b001 : 3'b111);
   assign wex = ((rex == 2'b00) && ~wcond) ? 2'b00 :
		((rex == 2'b11) && wcond) ? 2'b11 : wex_calc[1:0];

   pht prhisttbl
     (
      .clk(clk),
      .raddr_if(pc[2+:`GSH_BHR_LEN] ^ bhr_master),
      .raddr_ex(went),
      .waddr_ex(went),
      .rdata_if(rif),
      .rdata_ex(rex),
      .wdata_ex(wex),
      .we_ex(we)
      );
   

endmodule // gshare_predictor

module pht(
	   input wire 			 clk,
	   input wire [`GSH_PHT_SEL-1:0] raddr_if,
	   input wire [`GSH_PHT_SEL-1:0] raddr_ex,
	   input wire [`GSH_PHT_SEL-1:0] waddr_ex,
	   output wire [1:0] 		 rdata_if,
	   output wire [1:0] 		 rdata_ex,
	   input wire [1:0] 		 wdata_ex,
	   input wire 			 we_ex
	   );
   
   true_dualport_ram #(`GSH_PHT_SEL, 2, `GSH_PHT_NUM) pht0
     (
      .clka(~clk),
      .addra(raddr_if),
      .rdataa(rdata_if),
      .wdataa(),
      .wea(1'b0),
      .clkb(clk),
      .addrb(waddr_ex),
      .rdatab(),
      .wdatab(wdata_ex),
      .web(we_ex)
      );
   
   true_dualport_ram #(`GSH_PHT_SEL, 2, `GSH_PHT_NUM) pht1
     (
      .clka(~clk),
      .addra(raddr_ex),
      .rdataa(rdata_ex),
      .wdataa(),
      .wea(1'b0),
      .clkb(clk),
      .addrb(waddr_ex),
      .rdatab(),
      .wdatab(wdata_ex),
      .web(we_ex)
      );
   
endmodule // pht
`default_nettype wire
