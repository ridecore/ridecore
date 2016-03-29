`include "alu_ops.vh"
`include "rv32_opcodes.vh"

`default_nettype none
  
module alu(
           input wire [`ALU_OP_WIDTH-1:0] op,
           input wire [`XPR_LEN-1:0] 	  in1,
           input wire [`XPR_LEN-1:0] 	  in2,
           output reg [`XPR_LEN-1:0] 	  out
           );

   wire [`SHAMT_WIDTH-1:0] 	     shamt;

   assign shamt = in2[`SHAMT_WIDTH-1:0];

   always @(*) begin
      case (op)
        `ALU_OP_ADD : out = in1 + in2;
        `ALU_OP_SLL : out = in1 << shamt;
        `ALU_OP_XOR : out = in1 ^ in2;
        `ALU_OP_OR : out = in1 | in2;
        `ALU_OP_AND : out = in1 & in2;
        `ALU_OP_SRL : out = in1 >> shamt;
        `ALU_OP_SEQ : out = {31'b0, in1 == in2};
        `ALU_OP_SNE : out = {31'b0, in1 != in2};
        `ALU_OP_SUB : out = in1 - in2;
        `ALU_OP_SRA : out = $signed(in1) >>> shamt;
        `ALU_OP_SLT : out = {31'b0, $signed(in1) < $signed(in2)};
        `ALU_OP_SGE : out = {31'b0, $signed(in1) >= $signed(in2)};
        `ALU_OP_SLTU : out = {31'b0, in1 < in2};
        `ALU_OP_SGEU : out = {31'b0, in1 >= in2};
        default : out = 0;
      endcase // case op
   end


endmodule // alu

`default_nettype wire
