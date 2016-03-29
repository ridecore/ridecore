`include "constants.vh"
`include "rv32_opcodes.vh"

module singlecycproc();

   wire [`ADDR_LEN-1:0]      iraddr1;
   wire [`ADDR_LEN-1:0]      iraddr2 = 0;
   wire [`ADDR_LEN-1:0]      draddr1;
   wire [`ADDR_LEN-1:0]      draddr2 = 0;
   wire [`DATA_LEN-1:0]      irdata1;
   wire [`DATA_LEN-1:0]      irdata2;
   wire [`DATA_LEN-1:0]      drdata1;
   wire [`DATA_LEN-1:0]      drdata2;
   wire [1:0] 		     drsize1;
   wire [1:0] 		     drsize2 = 1;
   wire [`ADDR_LEN-1:0]      dwaddr1;
   wire [`ADDR_LEN-1:0]      dwaddr2 = 0;
   wire [`DATA_LEN-1:0]      dwdata1;
   wire [`DATA_LEN-1:0]      dwdata2 = 0;
   wire 		     dwe1;
   wire 		     dwe2 = 0;
   wire [1:0] 		     dwsize1;
   wire [1:0] 		     dwsize2 = 1;

   wire [6:0] 		     opcode;
   wire [`IMM_TYPE_WIDTH-1:0] imm_type;
   wire [`REG_SEL-1:0] 	      rs1;
   wire [`REG_SEL-1:0] 	      rs2;
   wire [`REG_SEL-1:0] 	      rd;
   wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel;
   wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel;
   wire 		       wr_reg;
   wire 		       ill_inst;
   wire 		       uses_rs1;
   wire 		       uses_rs2;
   wire [`ALU_OP_WIDTH-1:0]    alu_op;
   wire [`RS_ENT_SEL-1:0]      rs_ent;
   wire [2:0] 		       dmem_size;
   wire [`MEM_TYPE_WIDTH-1:0]  dmem_type;
   wire [`MD_OP_WIDTH-1:0]     md_req_op;
   wire 		       md_req_in_1_signed;
   wire 		       md_req_in_2_signed;
   wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel;

   wire [`DATA_LEN-1:0] 	imm;
   wire [`DATA_LEN-1:0] 	rs1_data;
   wire [`DATA_LEN-1:0] 	rs2_data;
   reg [`DATA_LEN-1:0] 		wb_data;

   wire [`DATA_LEN-1:0] 	alu_src_a;
   wire [`DATA_LEN-1:0] 	alu_src_b;
   wire [`DATA_LEN-1:0] 	alu_res;
   wire [`DATA_LEN-1:0] 	mul_res;
   wire [`DATA_LEN-1:0] 	load_dat;

   wire [`DATA_LEN-1:0] 	imm_br;
   wire [`DATA_LEN-1:0] 	imm_jal;
   wire [`DATA_LEN-1:0] 	imm_jalr;
   reg [`DATA_LEN-1:0] 		imm_j;
   
   reg [`ADDR_LEN-1:0] 		pc;
   reg [`ADDR_LEN-1:0] 		npc;
   
   
   parameter CLK_CYCLE_TIME = 50;
   parameter IMEM_INTERVAL = 2000;
   parameter SIM_CYCLE = 100000000;
   parameter SIM_TIME = SIM_CYCLE * CLK_CYCLE_TIME * 2;

   reg [31:0] 			CLK_CYCLE;
   reg 				clk;
   reg 				reset;
   
   initial begin
      clk = 0;
      forever #CLK_CYCLE_TIME clk = ~clk;
   end

   initial begin
      reset = 1;
      #IMEM_INTERVAL reset = 0;
   end

   initial begin
      CLK_CYCLE = 32'h0;
      #IMEM_INTERVAL CLK_CYCLE = 32'h0;
   end
   
   always @(posedge clk) begin
      CLK_CYCLE <= CLK_CYCLE + 1;
   end
   /*
    initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, TOP);
    end
    */    
   initial begin
      #IMEM_INTERVAL;
      #SIM_TIME;
      $finish;
   end

   always @ (posedge clk) begin
      if (reset) begin
	 pc <= 32'h0;
      end
      else begin
	 pc <= npc;
      end
   end

   assign iraddr1 = pc;
   assign opcode = irdata1[6:0];

   //512KB SRAM
   memory_nolatch
     simmem(
	    .clk(clk),
	    .iraddr1(iraddr1),
	    .iraddr2(iraddr2),
	    .draddr1(draddr1),
	    .draddr2(draddr2),
	    .irdata1(irdata1),
	    .irdata2(irdata2),
	    .drdata1(drdata1),
	    .drdata2(drdata2),
	    .drsize1(drsize1),
	    .drsize2(drsize2),
	    .dwaddr1(dwaddr1),
	    .dwaddr2(dwaddr2),
	    .dwdata1(dwdata1),
	    .dwdata2(dwdata2),
	    .dwe1(dwe1),
	    .dwe2(dwe2),
	    .dwsize1(dwsize1),
	    .dwsize2(dwsize2)
	    );
   
   decoder dcd(
	       .inst(irdata1),
	       .imm_type(imm_type),
	       .rs1(rs1),
	       .rs2(rs2),
	       .rd(rd),
	       .src_a_sel(src_a_sel),
	       .src_b_sel(src_b_sel),
	       .wr_reg(wr_reg),
	       .uses_rs1(uses_rs1),
	       .uses_rs2(uses_rs2),
	       .illegal_instruction(ill_inst),
	       .alu_op(alu_op),
	       .rs_ent(rs_ent),
	       .dmem_size(dmem_size),
	       .dmem_type(dmem_type),
	       .md_req_op(md_req_op),
	       .md_req_in_1_signed(md_req_in_1_signed),
	       .md_req_in_2_signed(md_req_in_2_signed),
	       .md_req_out_sel(md_req_out_sel)
	       );

   imm_gen ig(
	      .inst(irdata1),
	      .imm_type(imm_type),
	      .imm(imm)
	      );
   
   ram_sync_nolatch_2r1w #(`REG_SEL, `DATA_LEN, `REG_NUM)
     regfile(
	     .clk(clk),
	     .raddr1(rs1),
	     .raddr2(rs2),
	     .rdata1(rs1_data),
	     .rdata2(rs2_data),
	     .waddr(rd),
	     .wdata(wb_data),
	     .we(wr_reg && (rd != 0))
	     );

   src_a_mux sam(
		 .src_a_sel(src_a_sel),
		 .pc(pc),
		 .rs1(rs1_data),
		 .alu_src_a(alu_src_a)
		 );

   src_b_mux sbm(
		 .src_b_sel(src_b_sel),
		 .imm(imm),
		 .rs2(rs2_data),
		 .alu_src_b(alu_src_b)
		 );

   //ALICE so cute!
   alu alu_normal(
		  .op(alu_op),
		  .in1(alu_src_a),
		  .in2(alu_src_b),
		  .out(alu_res)
		  );

   //MULTIPLIER
   multiplier mpr(
		  .src1(rs1_data),
		  .src2(rs2_data),
		  .src1_signed(md_req_in_1_signed),
		  .src2_signed(md_req_in_2_signed),
		  .sel_lohi(md_req_out_sel[0]),
		  .result(mul_res)
		  );

   //LOAD UNIT
   assign draddr1 = alu_res;
   assign load_dat = drdata1;
   assign drsize1 = dmem_size[1:0];

   //STORE UNIT
   assign dwaddr1 = alu_res;
   assign dwsize1 = dmem_size[1:0];
   assign dwdata1 = rs2_data;
   assign dwe1 = (rs_ent == `RS_ENT_ST) ? 1 : 0;

   //BRANCH UNIT
   assign imm_br = { {20{irdata1[31]}}, irdata1[7], irdata1[30:25], irdata1[11:8], 1'b0 };
   assign imm_jal = { {12{irdata1[31]}}, irdata1[19:12], irdata1[20],
		       irdata1[30:25], irdata1[24:21], 1'b0 };
   assign imm_jalr = { {21{irdata1[31]}}, irdata1[30:21], 1'b0 };

   always @(*) begin
      case(rs_ent)
	`RS_ENT_LD: begin
	   wb_data = load_dat;
	end
	`RS_ENT_MUL: begin
	   wb_data = mul_res;
	end
	default: begin
	   wb_data = alu_res;
	end
      endcase
   end // always @ begin
   
   always @(*) begin
      case (opcode)
	`RV32_BRANCH: begin
	   npc = alu_res ? (pc + imm_br) : (pc + 4);
	end
	`RV32_JAL: begin
	   npc = pc + imm_jal;
	end
	`RV32_JALR: begin
	   npc = rs1_data + imm_jalr;
	end
	default: begin
	   npc = pc + 4;
	end
      endcase
   end // always @ begin
   
/*
   always @ (*) begin
      case (opcode)
	`RV32_BRANCH: imm_j = imm_br;
	`RV32_JAL: imm_j = imm_jal;
	default: imm_j = imm_jalr;
      endcase
   end
*/
   
   integer    fp;
   integer    temp;
   integer    i, j;
   initial begin
      fp = $fopen("../bin/init.bin", "rb");
      temp = $fread(simmem.mainmemory.mem0.mem, fp);
      fp = $fopen("../bin/init.bin", "rb");
      temp = $fread(simmem.mainmemory.mem1.mem, fp);
      for (i = 0; i < `REG_NUM ; i=i+1) begin
	 regfile.mem[i] = 0;
      end
      for (i = 0 ; i < 131072 ; i=i+1) begin
	 j = simmem.mainmemory.mem0.mem[i][7:0];
	 simmem.mainmemory.mem0.mem[i][7:0] = simmem.mainmemory.mem0.mem[i][31:24];
	 simmem.mainmemory.mem0.mem[i][31:24] = j;
	 j = simmem.mainmemory.mem0.mem[i][15:8];
	 simmem.mainmemory.mem0.mem[i][15:8] = simmem.mainmemory.mem0.mem[i][23:16];
	 simmem.mainmemory.mem0.mem[i][23:16] = j;
	 j = simmem.mainmemory.mem1.mem[i][7:0];
	 simmem.mainmemory.mem1.mem[i][7:0] = simmem.mainmemory.mem1.mem[i][31:24];
	 simmem.mainmemory.mem1.mem[i][31:24] = j;
	 j = simmem.mainmemory.mem1.mem[i][15:8];
	 simmem.mainmemory.mem1.mem[i][15:8] = simmem.mainmemory.mem1.mem[i][23:16];
	 simmem.mainmemory.mem1.mem[i][23:16] = j;
      end // for (i = 0 ; i < 131072 ; i=i+1)
/*
      for (i = 0 ; i < 1052 ; i = i + 1) begin
	 $write("%x: %d\n", i << 2, simmem.mainmemory.mem0.mem[i]);
      end
*/
   end

   always @(posedge clk) begin

/*      
      if (!reset) begin
	 $write("%x %x %x %x\n", pc, irdata1, wb_data, wr_reg);
      end
 */
/*
      if (!reset) begin
	 $write("%x %x %x %x %x %x %x %x %x %x %x\n", pc, irdata1, 
		alu_op, alu_res, load_dat, dwdata1, dwsize1, 
		dwe1, wb_data, wr_reg, rd);
      end
*/
      /*
      if(dwe1 && dwaddr1 == 32'h0) begin
         $write("%c", dwdata1[7:0]);
      end

      if(dwe1 && dwaddr1 == 32'h4) begin
         $write("%d", dwdata1);
      end
       */
      
      if(dwe1 && dwaddr1 == 32'h8) begin
	 $write("\n%d clks\n", CLK_CYCLE);
	 $finish;
      end    
      
      /*
      if (dwe1 && dwaddr1 != 0 && dwaddr1 != 4) begin
	 $write("%x %x\n", dwaddr1, dwdata1);
      end
       */
      if (~reset & wr_reg) begin
	 $write("%x %x %x %x\n", pc, wr_reg, rd, wb_data);
	 for (i = 1 ; i < `REG_NUM ; i=i+1) begin
	    $write("%x ", regfile.mem[i]);
	 end
	 $write("\n");
      end
/*
      if (~reset & dwe1) begin
	 $write("%x %x %x\n", pc, dwaddr1, dwdata1);
      end
*/
      /*      
       if(simmem.wren_delay && simmem.waddr_delay == 32'h0) begin
       $write("***\n %c \n***\n", dmem_wdata_delayed[7:0]);
      end
       */

      /*
       if(simmem.wren && simmem.waddr == 32'h0) begin
       $write("Delay:%c\n", dmem_wdata_delayed[7:0]);
      end
       
       if (dmem_wdata_delayed == 32'h41414141)
       $write("A wrote!!!\n");
       */
   end
endmodule // testbench
