`include "constants.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module brimm_gen
  (
   input wire [`INSN_LEN-1:0]  inst,
   output wire [`DATA_LEN-1:0] brimm
   );

   wire [`DATA_LEN-1:0]        br_offset = { {20{inst[31]}}, inst[7], 
					     inst[30:25], inst[11:8], 1'b0 };
   wire [`DATA_LEN-1:0]        jal_offset = { {12{inst[31]}}, inst[19:12], 
					      inst[20], inst[30:25], inst[24:21], 1'b0 };
   wire [`DATA_LEN-1:0]        jalr_offset = { {21{inst[31]}}, inst[30:21], 1'b0 };

   wire [6:0] 		       opcode = inst[6:0];
   
   assign brimm = (opcode == `RV32_BRANCH) ? br_offset :
		  (opcode == `RV32_JAL) ? jal_offset :
		  (opcode == `RV32_JALR) ? jalr_offset :
		  `DATA_LEN'b0;

endmodule // brimm_gen
`default_nettype wire  
