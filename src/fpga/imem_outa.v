module imem_outa
  (
   input [27:0]       pc,
   output reg [127:0] idata
   );

   always @ (*) begin
      case(pc)
	28'h0: idata = 128'h00202023001081130010202304100093;
	28'h1: idata = 128'h0000000000000000ffdff06f00202423;
	default: idata = 128'h0;
      endcase // case (pc)
   end
endmodule // imem_outa

