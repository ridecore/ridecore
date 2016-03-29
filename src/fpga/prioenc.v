`default_nettype none
module prioenc #(
		 parameter REQ_LEN = 4,
		 parameter GRANT_LEN = 2
		 )
   (
    input wire [REQ_LEN-1:0]   in,
    output reg [GRANT_LEN-1:0] out,
    output reg 		       en
   );
   
   integer 		      i;
   always @ (*) begin
      en = 0;
      out = 0;
      for (i = REQ_LEN-1 ; i >= 0 ; i = i - 1) begin
	 if (~in[i]) begin
	    out = i;
	    en = 1;
	 end
      end
   end
endmodule

module maskunit  #(
		   parameter REQ_LEN = 4,
		   parameter GRANT_LEN = 2
		   )
   (
    input wire [GRANT_LEN-1:0] mask,
    input wire [REQ_LEN-1:0]   in,
    output reg [REQ_LEN-1:0]   out
   );
   
   integer 		      i;
   always @ (*) begin
      out = 0;
      for (i = 0 ; i < REQ_LEN ; i = i+1) begin
	 out[i] = (mask < i) ? 1'b0 : 1'b1;
      end
   end
endmodule

module allocateunit  #(
		       parameter REQ_LEN = 4,
		       parameter GRANT_LEN = 2
		       )
   (
    input wire [REQ_LEN-1:0] 	busy,
    output wire 		en1,
    output wire 		en2,
    output wire [GRANT_LEN-1:0] free_ent1,
    output wire [GRANT_LEN-1:0] free_ent2,
    input wire [1:0] 		reqnum,
    output wire 		allocatable
   );
   
   wire [REQ_LEN-1:0] 	       busy_msk;
   
   prioenc #(REQ_LEN, GRANT_LEN) p1
     (
      .in(busy),
      .out(free_ent1),
      .en(en1)
      );

   maskunit #(REQ_LEN, GRANT_LEN) msku
     (
      .mask(free_ent1),
      .in(busy),
      .out(busy_msk)
      );
   
   prioenc #(REQ_LEN, GRANT_LEN) p2
     (
      .in(busy | busy_msk),
      .out(free_ent2),
      .en(en2)
      );

   assign allocatable = (reqnum > ({1'b0,en1}+{1'b0,en2})) ? 1'b0 : 1'b1;
endmodule
`default_nettype wire
