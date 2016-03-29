`default_nettype none

module oldest_finder2 #(
			parameter ENTLEN = 1,
			parameter VALLEN = 8
			)
  (
   input wire [2*ENTLEN-1:0] entvec,
   input wire [2*VALLEN-1:0] valvec,
   output wire [ENTLEN-1:0]  oldent,
   output wire [VALLEN-1:0]  oldval
   );
   //VALLEN = RRF_SEL+sortbit+~rdy
   
   wire [ENTLEN-1:0] 	     ent1 = entvec[0+:ENTLEN];
   wire [ENTLEN-1:0] 	     ent2 = entvec[ENTLEN+:ENTLEN];
   wire [VALLEN-1:0] 	     val1 = valvec[0+:VALLEN];
   wire [VALLEN-1:0] 	     val2 = valvec[VALLEN+:VALLEN];

   assign oldent = (val1 < val2) ? ent1 : ent2;
   assign oldval = (val1 < val2) ? val1 : val2;

endmodule // oldest_finder2

module oldest_finder4 #(
			parameter ENTLEN = 2,
			parameter VALLEN = 8
			)
   (
    input wire [4*ENTLEN-1:0] entvec,
    input wire [4*VALLEN-1:0] valvec,
    output wire [ENTLEN-1:0]  oldent,
    output wire [VALLEN-1:0]  oldval
   );
   //VALLEN = RRF_SEL+sortbit+~rdy

   wire [ENTLEN-1:0] 	     oldent1;
   wire [ENTLEN-1:0] 	     oldent2;
   wire [VALLEN-1:0] 	     oldval1;
   wire [VALLEN-1:0] 	     oldval2;

   oldest_finder2 #(ENTLEN, VALLEN) of2_1
     (
      .entvec({entvec[ENTLEN+:ENTLEN], entvec[0+:ENTLEN]}),
      .valvec({valvec[VALLEN+:VALLEN], valvec[0+:VALLEN]}),
      .oldent(oldent1),
      .oldval(oldval1)
      );

   oldest_finder2 #(ENTLEN, VALLEN) of2_2
     (
      .entvec({entvec[3*ENTLEN+:ENTLEN], entvec[2*ENTLEN+:ENTLEN]}),
      .valvec({valvec[3*VALLEN+:VALLEN], valvec[2*VALLEN+:VALLEN]}),
      .oldent(oldent2),
      .oldval(oldval2)
      );

   oldest_finder2 #(ENTLEN, VALLEN) ofmas
     (
      .entvec({oldent2, oldent1}),
      .valvec({oldval2, oldval1}),
      .oldent(oldent),
      .oldval(oldval)
      );
   
endmodule // oldest_finder4

module oldest_finder8 #(
			parameter ENTLEN = 3,
			parameter VALLEN = 8
			)
   (
    input wire [8*ENTLEN-1:0] entvec,
    input wire [8*VALLEN-1:0] valvec,
    output wire [ENTLEN-1:0]  oldent,
    output wire [VALLEN-1:0]  oldval
   );
   //VALLEN = RRF_SEL+sortbit+~rdy

   wire [ENTLEN-1:0] 	     oldent1;
   wire [ENTLEN-1:0] 	     oldent2;
   wire [VALLEN-1:0] 	     oldval1;
   wire [VALLEN-1:0] 	     oldval2;
   
   oldest_finder4 #(ENTLEN, VALLEN) of4_1
     (
      .entvec({entvec[3*ENTLEN+:ENTLEN], entvec[2*ENTLEN+:ENTLEN],
	       entvec[ENTLEN+:ENTLEN], entvec[0+:ENTLEN]}),
      .valvec({valvec[3*VALLEN+:VALLEN], valvec[2*VALLEN+:VALLEN],
	       valvec[VALLEN+:VALLEN], valvec[0+:VALLEN]}),
      .oldent(oldent1),
      .oldval(oldval1)
      );

   oldest_finder4 #(ENTLEN, VALLEN) of4_2
     (
      .entvec({entvec[7*ENTLEN+:ENTLEN], entvec[6*ENTLEN+:ENTLEN],
	       entvec[5*ENTLEN+:ENTLEN], entvec[4*ENTLEN+:ENTLEN]}),
      .valvec({valvec[7*VALLEN+:VALLEN], valvec[6*VALLEN+:VALLEN],
	       valvec[5*VALLEN+:VALLEN], valvec[4*VALLEN+:VALLEN]}),
      .oldent(oldent2),
      .oldval(oldval2)
      );

   oldest_finder2 #(ENTLEN, VALLEN) ofmas
     (
      .entvec({oldent2, oldent1}),
      .valvec({oldval2, oldval1}),
      .oldent(oldent),
      .oldval(oldval)
      );
   
endmodule // oldest_finder8

`default_nettype wire
