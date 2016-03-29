`include "rv32_opcodes.vh"
`include "constants.vh"
`default_nettype none
module src_a_mux(
                 input wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel,
                 input wire [`ADDR_LEN-1:0] 	   pc,
                 input wire [`DATA_LEN-1:0] 	   rs1,
                 output reg [`DATA_LEN-1:0] 	   alu_src_a
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
                 input wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel,
                 input wire [`DATA_LEN-1:0] 	   imm,
                 input wire [`DATA_LEN-1:0] 	   rs2,
                 output reg [`DATA_LEN-1:0] 	   alu_src_b
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
`default_nettype wire
