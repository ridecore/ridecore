`include "constants.vh"
`include "alu_ops.vh"
`default_nettype none
module exunit_alu
  (
   input wire 			     clk,
   input wire 			     reset,
   input wire [`DATA_LEN-1:0] 	     ex_src1,
   input wire [`DATA_LEN-1:0] 	     ex_src2,
   input wire [`ADDR_LEN-1:0] 	     pc,
   input wire [`DATA_LEN-1:0] 	     imm,
   input wire 			     dstval,
   input wire [`SRC_A_SEL_WIDTH-1:0] src_a,
   input wire [`SRC_B_SEL_WIDTH-1:0] src_b,
   input wire [`ALU_OP_WIDTH-1:0]    alu_op,
   input wire [`SPECTAG_LEN-1:0]     spectag,
   input wire 			     specbit,
   input wire 			     issue,
   input wire 			     prmiss,
   input wire [`SPECTAG_LEN-1:0]     spectagfix,
   output wire [`DATA_LEN-1:0] 	     result,
   output wire 			     rrf_we,
   output wire 			     rob_we, //set finish
   output wire 			     kill_speculative
   );

   wire [`DATA_LEN-1:0] 	alusrc1;
   wire [`DATA_LEN-1:0] 	alusrc2;

   reg 				busy;

   assign rob_we = busy;
   assign rrf_we = busy & dstval;
   assign kill_speculative = ((spectag & spectagfix) != 0) && specbit && prmiss;
   
   always @ (posedge clk) begin
      if (reset) begin
	 busy <= 0;
      end else begin
	 busy <= issue;
      end
   end
   
   src_a_mux samx
     (
      .src_a_sel(src_a),
      .pc(pc),
      .rs1(ex_src1),
      .alu_src_a(alusrc1)
      );

   src_b_mux sbmx
     (
      .src_b_sel(src_b),
      .imm(imm),
      .rs2(ex_src2),
      .alu_src_b(alusrc2)
      );

   alu alice
     (
      .op(alu_op),
      .in1(alusrc1),
      .in2(alusrc2),
      .out(result)
      );
endmodule // exunit_alu
`default_nettype wire
   
