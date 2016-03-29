`include "constants.vh"
`include "rv32_opcodes.vh"
`include "alu_ops.vh"

`default_nettype none
module decoder(
	       input wire [31:0] 		  inst,
	       output reg [`IMM_TYPE_WIDTH-1:0]   imm_type,
	       output wire [`REG_SEL-1:0] 	  rs1,
	       output wire [`REG_SEL-1:0] 	  rs2,
	       output wire [`REG_SEL-1:0] 	  rd,
	       output reg [`SRC_A_SEL_WIDTH-1:0]  src_a_sel,
               output reg [`SRC_B_SEL_WIDTH-1:0]  src_b_sel,
	       output reg 			  wr_reg,
	       
	       output reg 			  uses_rs1,
	       output reg 			  uses_rs2,
	       output reg 			  illegal_instruction,
	       output reg [`ALU_OP_WIDTH-1:0] 	  alu_op,
	       output reg [`RS_ENT_SEL-1:0] 	  rs_ent,
//	       output reg 			  dmem_use,
//	       output reg 			  dmem_write,
	       output wire [2:0] 		  dmem_size,
	       output wire [`MEM_TYPE_WIDTH-1:0]  dmem_type, 
	       output reg [`MD_OP_WIDTH-1:0] 	  md_req_op,
	       output reg 			  md_req_in_1_signed,
	       output reg 			  md_req_in_2_signed,
	       output reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel

	       );

   wire [`ALU_OP_WIDTH-1:0] 			  srl_or_sra;
   wire [`ALU_OP_WIDTH-1:0] 			  add_or_sub;
   wire [`RS_ENT_SEL-1:0] 			  rs_ent_md;
   
   wire [6:0] 		    opcode = inst[6:0];
   wire [6:0] 		    funct7 = inst[31:25];
   wire [11:0] 		    funct12 = inst[31:20];
   wire [2:0] 		    funct3 = inst[14:12];
// reg [`MD_OP_WIDTH-1:0]   md_req_op;
   reg [`ALU_OP_WIDTH-1:0]  alu_op_arith;
   
   assign rd = inst[11:7];
   assign rs1 = inst[19:15];
   assign rs2 = inst[24:20];

   assign dmem_size = {1'b0,funct3[1:0]};
   assign dmem_type = funct3;
   
   always @ (*) begin
      imm_type = `IMM_I;
      src_a_sel = `SRC_A_RS1;
      src_b_sel = `SRC_B_IMM;
      wr_reg = 1'b0;
      uses_rs1 = 1'b1;
      uses_rs2 = 1'b0;
      illegal_instruction = 1'b0;
      //      dmem_use = 1'b0;
      //     dmem_write = 1'b0;
      rs_ent = `RS_ENT_ALU;
      alu_op = `ALU_OP_ADD;
      
      case (opcode)
	`RV32_LOAD : begin
//           dmem_use = 1'b1;
           wr_reg = 1'b1;
	   rs_ent = `RS_ENT_LDST;
//           wb_src_sel_DX = `WB_SRC_MEM;
        end
        `RV32_STORE : begin
           uses_rs2 = 1'b1;
           imm_type = `IMM_S;
//           dmem_use = 1'b1;
 //          dmem_write = 1'b1;
	   rs_ent = `RS_ENT_LDST;
        end
        `RV32_BRANCH : begin
           uses_rs2 = 1'b1;
           //branch_taken_unkilled = cmp_true;
           src_b_sel = `SRC_B_RS2;
           case (funct3)
             `RV32_FUNCT3_BEQ : alu_op = `ALU_OP_SEQ;
             `RV32_FUNCT3_BNE : alu_op = `ALU_OP_SNE;
             `RV32_FUNCT3_BLT : alu_op = `ALU_OP_SLT;
             `RV32_FUNCT3_BLTU : alu_op = `ALU_OP_SLTU;
             `RV32_FUNCT3_BGE : alu_op = `ALU_OP_SGE;
             `RV32_FUNCT3_BGEU : alu_op = `ALU_OP_SGEU;
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
	   rs_ent = `RS_ENT_BRANCH;
        end
        `RV32_JAL : begin
	   //           jal_unkilled = 1'b1;
           uses_rs1 = 1'b0;
           src_a_sel = `SRC_A_PC;
           src_b_sel = `SRC_B_FOUR;
           wr_reg = 1'b1;
	   rs_ent = `RS_ENT_JAL;
        end
        `RV32_JALR : begin
           illegal_instruction = (funct3 != 0);
	   //           jalr_unkilled = 1'b1;
           src_a_sel = `SRC_A_PC;
           src_b_sel = `SRC_B_FOUR;
           wr_reg = 1'b1;
	   rs_ent = `RS_ENT_JALR;
        end
	/*
        `RV32_MISC_MEM : begin
           case (funct3)
             `RV32_FUNCT3_FENCE : begin
                if ((inst[31:28] == 0) && (rs1 == 0) && (reg_to_wr_DX == 0))
                  ; // most fences are no-ops
                else
                  illegal_instruction = 1'b1;
             end
             `RV32_FUNCT3_FENCE_I : begin
                if ((inst[31:20] == 0) && (rs1 == 0) && (reg_to_wr_DX == 0))
                  fence_i = 1'b1;
                else
                  illegal_instruction = 1'b1;
             end
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
	 */
        `RV32_OP_IMM : begin
           alu_op = alu_op_arith;
           wr_reg = 1'b1;
        end
        `RV32_OP  : begin
           uses_rs2 = 1'b1;
           src_b_sel = `SRC_B_RS2;
           alu_op = alu_op_arith;
           wr_reg = 1'b1;
           if (funct7 == `RV32_FUNCT7_MUL_DIV) begin
//              uses_md_unkilled = 1'b1;
	      rs_ent = rs_ent_md;
//              wb_src_sel_DX = `WB_SRC_MD;
           end
        end
	/*
        `RV32_SYSTEM : begin
           wb_src_sel_DX = `WB_SRC_CSR;
           wr_reg = (funct3 != `RV32_FUNCT3_PRIV);
           case (funct3)
             `RV32_FUNCT3_PRIV : begin
                if ((rs1 == 0) && (reg_to_wr_DX == 0)) begin
                   case (funct12)
                     `RV32_FUNCT12_ECALL : ecall = 1'b1;
                     `RV32_FUNCT12_EBREAK : ebreak = 1'b1;
                     `RV32_FUNCT12_ERET : begin
                        if (prv == 0)
                          illegal_instruction = 1'b1;
                        else
                          eret_unkilled = 1'b1;
                     end
                     default : illegal_instruction = 1'b1;
                   endcase // case (funct12)
                end // if ((rs1 == 0) && (reg_to_wr_DX == 0))
             end // case: `RV32_FUNCT3_PRIV
             `RV32_FUNCT3_CSRRW : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_WRITE;
             `RV32_FUNCT3_CSRRS : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_SET;
             `RV32_FUNCT3_CSRRC : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_CLEAR;
             `RV32_FUNCT3_CSRRWI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_WRITE;
             `RV32_FUNCT3_CSRRSI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_SET;
             `RV32_FUNCT3_CSRRCI : csr_cmd = (rs1 == 0) ? `CSR_READ : `CSR_CLEAR;
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
	 */
        `RV32_AUIPC : begin
           uses_rs1 = 1'b0;
           src_a_sel = `SRC_A_PC;
           imm_type = `IMM_U;
           wr_reg = 1'b1;
        end
        `RV32_LUI : begin
           uses_rs1 = 1'b0;
           src_a_sel = `SRC_A_ZERO;
           imm_type = `IMM_U;
           wr_reg = 1'b1;
        end
        default : begin
           illegal_instruction = 1'b1;
        end
      endcase // case (opcode)
   end // always @ (*)

   assign add_or_sub = ((opcode == `RV32_OP) && (funct7[5])) ? `ALU_OP_SUB : `ALU_OP_ADD;
   assign srl_or_sra = (funct7[5]) ? `ALU_OP_SRA : `ALU_OP_SRL;

   always @(*) begin
      case (funct3)
        `RV32_FUNCT3_ADD_SUB : alu_op_arith = add_or_sub;
        `RV32_FUNCT3_SLL : alu_op_arith = `ALU_OP_SLL;
        `RV32_FUNCT3_SLT : alu_op_arith = `ALU_OP_SLT;
        `RV32_FUNCT3_SLTU : alu_op_arith = `ALU_OP_SLTU;
        `RV32_FUNCT3_XOR : alu_op_arith = `ALU_OP_XOR;
        `RV32_FUNCT3_SRA_SRL : alu_op_arith = srl_or_sra;
        `RV32_FUNCT3_OR : alu_op_arith = `ALU_OP_OR;
        `RV32_FUNCT3_AND : alu_op_arith = `ALU_OP_AND;
        default : alu_op_arith = `ALU_OP_ADD;
      endcase // case (funct3)
   end // always @ begin


   //assign md_req_valid = uses_md;
   assign rs_ent_md = (
		       (funct3 == `RV32_FUNCT3_MUL) ||
		       (funct3 == `RV32_FUNCT3_MULH) ||
		       (funct3 == `RV32_FUNCT3_MULHSU) ||
		       (funct3 == `RV32_FUNCT3_MULHU)
		       ) ? `RS_ENT_MUL : `RS_ENT_DIV;
   
   always @(*) begin
      md_req_op = `MD_OP_MUL;
      md_req_in_1_signed = 0;
      md_req_in_2_signed = 0;
      md_req_out_sel = `MD_OUT_LO;
      case (funct3)
        `RV32_FUNCT3_MUL : begin
        end
        `RV32_FUNCT3_MULH : begin
           md_req_in_1_signed = 1;
           md_req_in_2_signed = 1;
           md_req_out_sel = `MD_OUT_HI;
        end
        `RV32_FUNCT3_MULHSU : begin
           md_req_in_1_signed = 1;
           md_req_out_sel = `MD_OUT_HI;
        end
        `RV32_FUNCT3_MULHU : begin
           md_req_out_sel = `MD_OUT_HI;
        end
        `RV32_FUNCT3_DIV : begin
           md_req_op = `MD_OP_DIV;
           md_req_in_1_signed = 1;
           md_req_in_2_signed = 1;
        end
        `RV32_FUNCT3_DIVU : begin
           md_req_op = `MD_OP_DIV;
        end
        `RV32_FUNCT3_REM : begin
           md_req_op = `MD_OP_REM;
           md_req_in_1_signed = 1;
           md_req_in_2_signed = 1;
           md_req_out_sel = `MD_OUT_REM;
        end
        `RV32_FUNCT3_REMU : begin
           md_req_op = `MD_OP_REM;
           md_req_out_sel = `MD_OUT_REM;
        end
      endcase
   end

   
endmodule // decoder
`default_nettype wire
