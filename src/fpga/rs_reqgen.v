`include "constants.vh"
`default_nettype none
module rs_requestgenerator
  (
   input wire [`RS_ENT_SEL-1:0] rsent_1,
   input wire [`RS_ENT_SEL-1:0] rsent_2,
   output wire 			req1_alu,
   output wire 			req2_alu,
   output wire [1:0] 		req_alunum,
   output wire 			req1_branch,
   output wire 			req2_branch,
   output wire [1:0] 		req_branchnum,
   output wire 			req1_mul,
   output wire 			req2_mul,
   output wire [1:0] 		req_mulnum,
   output wire 			req1_ldst,
   output wire 			req2_ldst,
   output wire [1:0] 		req_ldstnum
   );

   assign req1_alu = (rsent_1 == `RS_ENT_ALU) ? 1'b1 : 1'b0;
   assign req2_alu = (rsent_2 == `RS_ENT_ALU) ? 1'b1 : 1'b0;
   assign req_alunum = {1'b0, req1_alu} + {1'b0, req2_alu};

   assign req1_branch = (rsent_1 == `RS_ENT_BRANCH) ? 1'b1 : 1'b0;
   assign req2_branch = (rsent_2 == `RS_ENT_BRANCH) ? 1'b1 : 1'b0;
   assign req_branchnum = {1'b0, req1_branch} + {1'b0, req2_branch};

   assign req1_mul = (rsent_1 == `RS_ENT_MUL) ? 1'b1 : 1'b0;
   assign req2_mul = (rsent_2 == `RS_ENT_MUL) ? 1'b1 : 1'b0;
   assign req_mulnum = {1'b0, req1_mul} + {1'b0, req2_mul};

   assign req1_ldst = (rsent_1 == `RS_ENT_LDST) ? 1'b1 : 1'b0;
   assign req2_ldst = (rsent_2 == `RS_ENT_LDST) ? 1'b1 : 1'b0;
   assign req_ldstnum = {1'b0, req1_ldst} + {1'b0, req2_ldst};
   
endmodule // rs_requestgenerator
`default_nettype wire
