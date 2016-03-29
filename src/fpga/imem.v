`include "constants.vh"
`default_nettype none
// 8KB Instruction Memory (32bit*4way)
module imem(
	    input wire 			 clk,
	    input wire [8:0] 		 addr,
	    output reg [`INSN_LEN*4-1:0] data
	    );
   reg [`INSN_LEN*4-1:0] 		 mem[0:511];
   always @ (posedge clk) begin
      data <= mem[addr];
   end
endmodule // imem

module imem_ld(
	       input wire 		    clk,
	       input wire [8:0] 	    addr,
	       output reg [4*`INSN_LEN-1:0] rdata,
	       input wire [4*`INSN_LEN-1:0] wdata,
	       input wire we
	       );
   reg [`INSN_LEN*4-1:0] 		 mem[0:511];
   always @ (posedge clk) begin
      rdata <= mem[addr];
      if (we) begin
	 mem[addr] <= wdata;
      end
   end
endmodule
`default_nettype wire
