`include "rv32_opcodes.vh"
`include "constants.vh"

module src_prf_or_arf(
		      input 		     valid1,
		      input 		     valid2,
		      input 		     pend1,
		      input 		     pend2,
		      input [`DATA_LEN-1:0]  areg1,
		      input [`DATA_LEN-1:0]  areg2,
		      input [`DATA_LEN-1:0]  prf_data1,
		      input [`DATA_LEN-1:0]  prf_data2,
		      input [`REG_SEL-1:0]   rt_data1,
		      input [`REG_SEL-1:0]   rt_data2,
		      output [`DATA_LEN-1:0] rs1,
		      output [`DATA_LEN-1:0] rs2,
		      output 		     inflight1,
		      output 		     inflight2
		      );

   wire [`DATA_LEN-1:0] 		     rt_data1_ext = {27'b0, rt_data1};
   wire [`DATA_LEN-1:0] 		     rt_data2_ext = {27'b0, rt_data2};

   assign rs1 = valid1 ? (pend1 ? rt_data1_ext : rob_data1) : areg1;
   assign rs2 = valid2 ? (pend2 ? rt_data2_ext : rob_data2) : areg2;

   assign inflight1 = valid1 & pend1;
   assign inflight2 = valid2 & pend2;
endmodule // src_prf_or_arf

module forwarding_mux(
		      input [`DATA_LEN-1:0]  src1,
		      input [`DATA_LEN-1:0]  src2,
		      input [`PRF_SEL-1:0]   fwdrobent1,
		      input [`DATA_LEN-1:0]  fwdrobdata1,
		      input 		     robwe1,
		      input [`PRF_SEL-1:0]   fwdrobent2,
		      input [`DATA_LEN-1:0]  fwdrobdata2,
		      input 		     robwe2,
		      input [`PRF_SEL-1:0]   fwdrobent1_dly,
		      input [`DATA_LEN-1:0]  fwdrobdata1_dly,
		      input 		     robwe1_dly,
		      input [`PRF_SEL-1:0]   fwdrobent2_dly,
		      input [`DATA_LEN-1:0]  fwdrobdata2_dly,
		      input 		     robwe2_dly,
		      input 		     inflight1,
		      input 		     inflight2,
		      output [`DATA_LEN-1:0] fwdsrc1,
		      output [`DATA_LEN-1:0] fwdsrc2,
		      output 		     inflight_solved1,
		      output 		     inflight_solved2
		      );
   
   wire [`REG_SEL-1:0] 			     prf1 = src1[`REG_SEL-1:0];
   wire [`REG_SEL-1:0] 			     prf2 = src2[`REG_SEL-1:0];

   assign inflight_solved1 = ~inflight1 ||
			     (prf1 == fwdrobent1) && robwe1 ||
			     (prf1 == fwdrobent2) && robwe2 ||
			     (prf1 == fwdrobent1_dly) && robwe1_dly ||
			     (prf1 == fwdrobent2_dly) && robwe2_dly;
   
   assign fwdsrc1 = ~inflight1 ? src1 :
		    (prf1 == fwdrobent1) && robwe1   ? fwdrobdata1 :
		    (prf1 == fwdrobent2) && robwe2   ? fwdrobdata2 :
		    (prf1 == fwdrobent1_dly) && robwe1_dly ? fwdrobdata1_dly :
		    (prf1 == fwdrobent2_dly) && robwe2_dly ? fwdrobdata2_dly :
		    src1;

   assign inflight_solved2 = ~inflight2 ||
			     (prf2 == fwdrobent1) && robwe1 ||
			     (prf2 == fwdrobent2) && robwe2 ||
			     (prf2 == fwdrobent1_dly) && robwe1_dly ||
			     (prf2 == fwdrobent2_dly) && robwe2_dly;
   
   assign fwdsrc2 = ~inflight2 ? src2 :
		    (prf2 == fwdrobent1) && robwe1   ? fwdrobdata1 :
		    (prf2 == fwdrobent2) && robwe2   ? fwdrobdata2 :
		    (prf2 == fwdrobent1_dly) && robwe1_dly ? fwdrobdata1_dly :
		    (prf2 == fwdrobent2_dly) && robwe2_dly ? fwdrobdata2_dly :
		    src2;

endmodule // forwarding_mux

module src_a_mux(
                 input [`SRC_A_SEL_WIDTH-1:0] src_a_sel,
                 input [`ADDR_LEN-1:0] 	      pc,
                 input [`DATA_LEN-1:0] 	      rs1,
                 output reg [`DATA_LEN-1:0]   alu_src_a
                 );


   always @(*) begin
      case (src_a_sel)
        `SRC_A_RS1 : alu_src_a = rs1;
        `SRC_A_PC : alu_src_a = pc;
        default : alu_src_a = 0;
      endcase // case (src_a_sel)
   end

endmodule // src_a_mux

module src_b_mux(
                 input [`SRC_B_SEL_WIDTH-1:0] src_b_sel,
                 input [`DATA_LEN-1:0] 	      imm,
                 input [`DATA_LEN-1:0] 	      rs2,
                 output reg [`DATA_LEN-1:0]   alu_src_b
                 );


   always @(*) begin
      case (src_b_sel)
        `SRC_B_RS2 : alu_src_b = rs2;
        `SRC_B_IMM : alu_src_b = imm;
        `SRC_B_FOUR : alu_src_b = 4;
        default : alu_src_b = 0;
      endcase // case (src_b_sel)
   end

endmodule // src_b_mux
