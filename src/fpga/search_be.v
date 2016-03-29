
module search_begin #(
		      parameter ENTSEL = 2,
		      parameter ENTNUM = 4
		     )
  (
   input wire [ENTNUM-1:0] in,
   output reg [ENTSEL-1:0] out,
   output reg 		   en
   );

   integer 		   i;
   always @ (*) begin
      out = 0;
      en = 0;
      for (i = ENTNUM-1; i >= 0 ; i = i - 1) begin
	 if (in[i]) begin
	    out = i;
	    en = 1;
	 end
      end
   end
   
endmodule // search_from_top

module search_end #(
		    parameter ENTSEL = 2,
		    parameter ENTNUM = 4
		    )
   (
    input wire [ENTNUM-1:0] in,
    output reg [ENTSEL-1:0] out,
    output reg 		    en
   );

   integer 		   i;
   always @ (*) begin
      out = 0;
      en = 0;
      for (i = 0 ; i < ENTNUM ; i = i + 1) begin
	 if (in[i]) begin
	    out = i;
	    en = 1;
	 end
      end
   end

endmodule // search_from_bottom
