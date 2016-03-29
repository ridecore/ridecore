`include "constants.vh"
`default_nettype none
module btb(
	   input wire 		       clk,
	   input wire 		       reset,
	   input wire [`ADDR_LEN-1:0]  pc,
	   output wire 		       hit,
	   output wire [`ADDR_LEN-1:0] jmpaddr,
	   input wire 		       we,
	   input wire [`ADDR_LEN-1:0]  jmpsrc,
	   input wire [`ADDR_LEN-1:0]  jmpdst,
	   input wire 		       invalid2
	   );

   wire [`ADDR_LEN-1:0] 	  tag_data;
   reg [`BTB_IDX_NUM-1:0] 	  valid;
   wire [`BTB_IDX_SEL-1:0] 	  waddr = jmpsrc[3+:`BTB_IDX_SEL];
   wire [`ADDR_LEN-1:0] 	  pc2 = pc+4;
   
   wire 			  hit1 = ((tag_data == pc) && valid[pc[3+:`BTB_IDX_SEL]]) ? 
				  1'b1 : 1'b0;
   wire 			  hit2 = ((tag_data == pc2) && ~invalid2 
					  && valid[pc[3+:`BTB_IDX_SEL]]) ? 1'b1 : 1'b0;
   assign hit = hit1 | hit2;
		
   always @ (negedge clk) begin
      if (reset) begin
	 valid <= 0;
      end else begin
	 if (we) begin
	    valid[waddr] <= 1'b1;
	 end
      end
   end
   
   ram_sync_1r1w #(`BTB_IDX_SEL, `ADDR_LEN, `BTB_IDX_NUM) bia
     (
      .clk(~clk),
      .raddr1(pc[3+:`BTB_IDX_SEL]),
      .rdata1(tag_data),
      .waddr(waddr),
//    .wdata(jmpsrc[31:3+`BTB_IDX_SEL]),
      .wdata(jmpsrc),
      .we(we)
      );

   ram_sync_1r1w #(`BTB_IDX_SEL, `ADDR_LEN, `BTB_IDX_NUM) bta
     (
      .clk(~clk),
      .raddr1(pc[3+:`BTB_IDX_SEL]),
      .rdata1(jmpaddr),
      .waddr(waddr),
      .wdata(jmpdst),
      .we(we)
      );
        
endmodule // btb
`default_nettype wire
