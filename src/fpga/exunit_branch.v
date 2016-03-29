`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype none
module exunit_branch
  (
   input wire 			  clk,
   input wire 			  reset,
   input wire [`DATA_LEN-1:0] 	  ex_src1,
   input wire [`DATA_LEN-1:0] 	  ex_src2,
   input wire [`ADDR_LEN-1:0] 	  pc,
   input wire [`DATA_LEN-1:0] 	  imm,
   input wire 			  dstval,
   input wire [`ALU_OP_WIDTH-1:0] alu_op,
   input wire [`SPECTAG_LEN-1:0]  spectag,
   input wire 			  specbit,
   input wire [`ADDR_LEN-1:0] 	  praddr,
   input wire [6:0] 		  opcode,
   input wire 			  issue,
   output wire [`DATA_LEN-1:0] 	  result,
   output wire 			  rrf_we,
   output wire 			  rob_we, //set finish
   output wire 			  prsuccess,
   output wire 			  prmiss,
   output wire [`ADDR_LEN-1:0] 	  jmpaddr,
   output wire [`ADDR_LEN-1:0] 	  jmpaddr_taken,
   output wire 			  brcond,
   output wire [`SPECTAG_LEN-1:0] tagregfix
   );

   reg 			       busy;
   
   wire [`DATA_LEN-1:0]        comprslt;
   wire 		       addrmatch = (jmpaddr == praddr) ? 1'b1 : 1'b0;

   
   assign rob_we = busy;
   assign rrf_we = busy & dstval;
   assign result = pc + 4;
   assign prsuccess = busy & addrmatch;
   assign prmiss = busy & ~addrmatch;
   assign jmpaddr = brcond ? jmpaddr_taken : (pc + 4);
   assign jmpaddr_taken = (((opcode == `RV32_JALR) ? ex_src1 : pc) + imm);
   
   assign brcond = ((opcode == `RV32_JAL) || (opcode == `RV32_JALR)) ?
			       1'b1 : comprslt[0];
   assign tagregfix = {spectag[0], spectag[`SPECTAG_LEN-1:1]};
   
   always @ (posedge clk) begin
      if (reset) begin
	 busy <= 0;
      end else begin
	 busy <= issue;
      end
   end
		  
   alu comparator
     (
      .op(alu_op),
      .in1(ex_src1),
      .in2(ex_src2),
      .out(comprslt)
      );
   
endmodule // exunit_branch

`default_nettype wire
