`include "constants.vh"

//`default_nettype none
  
module alloc_issue_ino  #(
			  parameter ENTSEL = 2,
			  parameter ENTNUM = 4
			  )
   (
    input wire 		     clk,
    input wire 		     reset,
    input wire [1:0] 	     reqnum,
    input wire [ENTNUM-1:0]  busyvec,
    input wire [ENTNUM-1:0]  prbusyvec_next,
    input wire [ENTNUM-1:0]  readyvec,
    input wire 		     prmiss,
    input wire 		     exunit_busynext,
    input wire 		     stall_DP,
    input wire 		     kill_DP,
    output reg [ENTSEL-1:0]  allocptr,
    output wire 	     allocatable,
    output wire [ENTSEL-1:0] issueptr,
    output wire 	     issuevalid
   );


   wire [ENTSEL-1:0] 	    allocptr2 = allocptr + 1;
   wire [ENTSEL-1:0] 	    b0;
   wire [ENTSEL-1:0] 	    e0;
   wire [ENTSEL-1:0] 	    b1;
   wire [ENTSEL-1:0] 	    e1;
   wire 		    notfull;

   wire [ENTSEL-1:0] 	    ne1;
   wire [ENTSEL-1:0] 	    nb0;
   wire [ENTSEL-1:0] 	    nb1;
   wire 		    notfull_next;
   
   search_begin #(ENTSEL, ENTNUM) sb1(
				      .in(busyvec),
				      .out(b1),
				      .en()
				      );
   
   search_end #(ENTSEL, ENTNUM) se1(
				    .in(busyvec),
				    .out(e1),
				    .en()
				    );

   search_end #(ENTSEL, ENTNUM) se0(
				    .in(~busyvec),
				    .out(e0),
				    .en(notfull)
				    );

   search_begin #(ENTSEL, ENTNUM) snb1(
				       .in(prbusyvec_next),
				       .out(nb1),
				       .en()
				       );
   
   search_end #(ENTSEL, ENTNUM) sne1(
				     .in(prbusyvec_next),
				     .out(ne1),
				     .en()
				     );

   search_begin #(ENTSEL, ENTNUM) snb0(
				       .in(~prbusyvec_next),
				       .out(nb0),
				       .en(notfull_next)
				       );

   assign issueptr = ~notfull ? allocptr :
		     ((b1 == 0) && (e1 == ENTNUM-1)) ? (e0+1) : 
		     b1;
   
   assign issuevalid = readyvec[issueptr] & ~prmiss & ~exunit_busynext;

   assign allocatable = (reqnum == 2'h0) ? 1'b1 :
			(reqnum == 2'h1) ? ((~busyvec[allocptr] ? 1'b1 : 1'b0)) :
			((~busyvec[allocptr] && ~busyvec[allocptr2]) ? 1'b1 : 1'b0);
   
   always @ (posedge clk) begin
      if (reset) begin
	 allocptr <= 0;
      end else if (prmiss) begin
	 allocptr <= ~notfull_next ? allocptr :
		     (((nb1 == 0) && (ne1 == ENTNUM-1)) ? nb0 : (ne1+1));
      end else if (~stall_DP && ~kill_DP) begin
	 allocptr <= allocptr + reqnum;
      end
   end
endmodule // alloc_issue_ino

//`default_nettype wire
