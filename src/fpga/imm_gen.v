`include "constants.vh"
`default_nettype none
module imm_gen(
               input wire [`INSN_LEN-1:0] 	inst,
               input wire [`IMM_TYPE_WIDTH-1:0] imm_type,
               output reg [`DATA_LEN-1:0] 	imm
               );

   always @(*) begin
      case (imm_type)
        `IMM_I : imm = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };
        `IMM_S : imm = { {21{inst[31]}}, inst[30:25], inst[11:8], inst[7] };
        `IMM_U : imm = { inst[31], inst[30:20], inst[19:12], 12'b0 };
        `IMM_J : imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };
        default : imm = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };
      endcase // case (imm_type)
   end

endmodule // imm_gen




`default_nettype wire
