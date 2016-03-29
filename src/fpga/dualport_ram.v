`include "constants.vh"
`default_nettype none
module true_dualport_ram #(
			   parameter ADDRLEN = 10,
			   parameter DATALEN = 2,
			   parameter DEPTH = 1024
			   )
   (
    input wire 		     clka,
    input wire [ADDRLEN-1:0] addra,
    output reg [DATALEN-1:0] rdataa,
    input wire [DATALEN-1:0] wdataa,
    input wire 		     wea,
    input wire 		     clkb,
    input wire [ADDRLEN-1:0] addrb,
    output reg [DATALEN-1:0] rdatab,
    input wire [DATALEN-1:0] wdatab,
    input wire 		     web
    );


   reg [DATALEN-1:0] 				  mem [0:DEPTH-1];
   
   always @ (posedge clka) begin
      rdataa <= mem[addra];
      if (wea) begin
	 mem[addra] <= wdataa;
      end
   end

   always @ (posedge clkb) begin
      rdatab <= mem[addrb];
      if (web) begin
	 mem[addrb] <= wdatab;
      end
   end
endmodule // true_dualport_ram

module true_dualport_ram_clear #(
				 parameter ADDRLEN = 10,
				 parameter DATALEN = 2,
				 parameter DEPTH = 1024
				 )
   (
    input wire 		     clka,
    input wire [ADDRLEN-1:0] addra,
    output reg [DATALEN-1:0] rdataa,
    input wire [DATALEN-1:0] wdataa,
    input wire 		     wea,
    input wire 		     clkb,
    input wire [ADDRLEN-1:0] addrb,
    output reg [DATALEN-1:0] rdatab,
    input wire [DATALEN-1:0] wdatab,
    input wire 		     web,
    input wire 		     clear
    );

   reg [DATALEN-1:0] 					mem [0:DEPTH-1];
   integer 						i;
   
   always @ (*) begin
      if (clear) begin
	 for (i=0; i<DEPTH; i=i+1)
	   mem[i] = 0;
      end
   end
   
   always @ (posedge clka) begin
      rdataa <= mem[addra];
      if (wea) begin
	 mem[addra] <= wdataa;
      end
   end

   always @ (posedge clkb) begin
      rdatab <= mem[addrb];
      if (web) begin
	 mem[addrb] <= wdatab;
      end
   end
endmodule // true_dualport_ram
`default_nettype wire
