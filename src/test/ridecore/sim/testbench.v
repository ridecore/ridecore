`include "constants.vh"
`include "rv32_opcodes.vh"

module testbench();
   parameter CLK_CYCLE_TIME = 50;
   parameter IMEM_INTERVAL = 2000;
   parameter SIM_CYCLE = 10000000;
   parameter SIM_TIME = SIM_CYCLE * CLK_CYCLE_TIME * 2;
   parameter init_file = "../bin/init.bin";

   reg [31:0] 			CLK_CYCLE;
   reg 				clk;
   reg 				reset;
   
   initial begin
      clk = 0;
      forever #CLK_CYCLE_TIME clk = ~clk;
   end

   initial begin
      reset = 0;
      #IMEM_INTERVAL reset = 1;
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
    $dumpvars(0, testbench);
    end
    */

   initial begin
      #IMEM_INTERVAL;
      #SIM_TIME;
      $finish;
   end

   top rv(
	  .clk(clk),
	  .reset_x(reset)
	  );
   
   integer    fp;
   integer    temp;
   integer    i, j;
   
   initial begin
      //btb, bia init
      for (i = 0; i < `BTB_IDX_NUM ; i = i + 1) begin
	 rv.pipe.pipe_if.brtbl.bia.mem[i] = 0;
	 rv.pipe.pipe_if.brtbl.bta.mem[i] = 0;
      end

      for (i = 0; i < `GSH_PHT_NUM ; i = i + 1) begin
	 rv.pipe.pipe_if.gsh.prhisttbl.pht0.mem[i] = 3;
	 rv.pipe.pipe_if.gsh.prhisttbl.pht1.mem[i] = 3;
      end
      
      fp = $fopen(init_file, "rb");
      temp = $fread(rv.instmemory.mem, fp);
      fp = $fopen(init_file, "rb");
      temp = $fread(rv.datamemory.mem, fp);

      for (i = 0 ; i < 512 ; i = i + 1) begin
	 j = rv.instmemory.mem[i][7:0];
	 rv.instmemory.mem[i][7:0] = rv.instmemory.mem[i][31:24];
	 rv.instmemory.mem[i][31:24] = j;
	 j = rv.instmemory.mem[i][15:8];
	 rv.instmemory.mem[i][15:8] = rv.instmemory.mem[i][23:16];
	 rv.instmemory.mem[i][23:16] = j;

	 j = rv.instmemory.mem[i][32+7:0+32];
	 rv.instmemory.mem[i][32+7:0+32] 
	   = rv.instmemory.mem[i][32+31:24+32];
	 rv.instmemory.mem[i][32+31:24+32] = j;
	 j = rv.instmemory.mem[i][32+15:8+32];
	 rv.instmemory.mem[i][32+15:8+32] 
	   = rv.instmemory.mem[i][32+23:16+32];
	 rv.instmemory.mem[i][32+23:16+32] = j;
	 
	 j = rv.instmemory.mem[i][64+7:0+64];
	 rv.instmemory.mem[i][64+7:0+64] 
	   = rv.instmemory.mem[i][64+31:24+64];
	 rv.instmemory.mem[i][64+31:24+64] = j;
	 j = rv.instmemory.mem[i][64+15:8+64];
	 rv.instmemory.mem[i][64+15:8+64] 
	   = rv.instmemory.mem[i][64+23:16+64];
	 rv.instmemory.mem[i][64+23:16+64] = j;

	 j = rv.instmemory.mem[i][96+7:0+96];
	 rv.instmemory.mem[i][96+7:0+96] 
	   = rv.instmemory.mem[i][96+31:24+96];
	 rv.instmemory.mem[i][96+31:24+96] = j;
	 j = rv.instmemory.mem[i][96+15:8+96];
	 rv.instmemory.mem[i][96+15:8+96] 
	   = rv.instmemory.mem[i][96+23:16+96];
	 rv.instmemory.mem[i][96+23:16+96] = j;

	 j = rv.instmemory.mem[i][31:0];
	 rv.instmemory.mem[i][31:0] = rv.instmemory.mem[i][127:96];
	 rv.instmemory.mem[i][127:96] = j;
	 j = rv.instmemory.mem[i][63:32];
	 rv.instmemory.mem[i][63:32] = rv.instmemory.mem[i][95:64];
	 rv.instmemory.mem[i][95:64] = j;
      end
      for (i = 0 ; i < 2048 ; i = i + 1) begin
	 j = rv.datamemory.mem[i][7:0];
	 rv.datamemory.mem[i][7:0] = rv.datamemory.mem[i][31:24];
	 rv.datamemory.mem[i][31:24] = j;
	 j = rv.datamemory.mem[i][15:8];
	 rv.datamemory.mem[i][15:8] = rv.datamemory.mem[i][23:16];
	 rv.datamemory.mem[i][23:16] = j;
      end

      //meminitialization check imem OK!!
      /*
       for (i = 0 ; i < 512 ; i = i + 1) begin
       $write("%x: %x\n", i*16, rv.instmemory.mem[i][31:0]);
       $write("%x: %x\n", 4 + i*16, rv.instmemory.mem[i][63:32]);
       $write("%x: %x\n", 8 + i*16, rv.instmemory.mem[i][95:64]);
       $write("%x: %x\n", 12 + i*16, rv.instmemory.mem[i][127:96]);
      end
       */
      //meminitialization check dmem OK!!
      /*
       for (i = 0 ; i < 2048 ; i = i + 1) begin
       $write("%x; %d\n", i << 2, rv.datamemory.mem[i]);
      end
       */
   end
   /*
    always @ (negedge clk) begin
    if (reset) begin
    $write("neg\n%x: %x %x %x %x %x %x %x\n", 
    rv.pipe.pc, rv.pipe.pipe_if.npc, 
    rv.pipe.pipe_if.invalid2, rv.pipe.pipe_if.hit, rv.pipe.pipe_if.predict_cond, 
    rv.pipe.pipe_if.brtbl.we, rv.pipe.prmiss, rv.pipe.prsuccess);
      end
   end // always @ (negedge clk)
    */

   integer stall, stall_ldst, stall_branch, stall_prsuccess;
   initial begin
      stall = 0;
      stall_ldst = 0;
      stall_branch = 0;
      stall_prsuccess = 0;
   end

   always @ (posedge clk) begin
      if (rv.pipe.stall_IF || rv.pipe.stall_ID || rv.pipe.stall_DP) begin
	 stall = stall + 1;
	 if (rv.pipe.allocatable_alu && ~rv.pipe.prsuccess &&
	     rv.pipe.allocatable_mul && rv.pipe.allocatable_branch &&
	     rv.pipe.alloc_rrf && ~rv.pipe.allocatable_ldst) begin
	    stall_ldst = stall_ldst + 1;
	 end
	 if (~rv.pipe.allocatable_branch) begin
	    stall_branch = stall_branch + 1;
	 end
	 if (rv.pipe.prsuccess) begin
	    stall_prsuccess = stall_prsuccess + 1;
	 end
      end
   end

   integer prmi, prsu, prnum, prcom;
   initial begin
      prmi = 0;
      prsu = 0;
      prnum = 0;
      prcom = 0;
   end
   
   always @ (posedge clk) begin
      if (reset && rv.pipe.prmiss) begin
	 prmi = prmi + 1;
	 prnum = prnum + 1;
	 //$write("Miss: npc: %x\n", rv.pipe.jmpaddr);
      end
      if (reset && rv.pipe.prsuccess) begin
	 prsu = prsu + 1;
	 prnum = prnum + 1;
	 //$write("Success: npc: %x\n", rv.pipe.jmpaddr);
      end
      if (reset && rv.pipe.combranch) begin
	 prcom = prcom + 1;
	 //$write("PC: %x, DST: %x\n", rv.pipe.pc_combranch, rv.pipe.jmpaddr_combranch);
      end
   end

   
   always @ (posedge clk) begin
      
      $write("-----------------------------------------------------------\n");
      
      if (reset) begin
	 /*
	  if (rv.pipe.pipe_if.hit && ~rv.pipe.stall_IF && ~rv.pipe.kill_IF) begin
	  $write("Prediction HIT!!!!!!!! Info\n");
	  $write("pc: %x jmpaddr: %x npc: %x prcond: %x\n",
	  rv.pipe.pipe_if.pc, rv.pipe.pipe_if.pred_pc, rv.pipe.npc, rv.pipe.pipe_if.predict_cond);
	  
	 end
	  */
	 $write("Stall/Kill Sig f:%x %x d:%x %x p:%x %x; %x %x %x %x %x\n", 
		rv.pipe.stall_IF, rv.pipe.kill_IF,
		rv.pipe.stall_ID, rv.pipe.kill_ID, rv.pipe.stall_DP, rv.pipe.kill_DP,
		rv.pipe.allocatable_alu, rv.pipe.allocatable_ldst, rv.pipe.allocatable_mul,
		rv.pipe.allocatable_branch, rv.pipe.alloc_rrf);
      end
      
      //IF_latch
      if (reset) begin
	 $write("IFL\n%x: %x %x %x\n", rv.pipe.pc_if, rv.pipe.inst1_if, rv.pipe.inst2_if, rv.pipe.combranch);
      end

      //ID_latch
      if (reset) begin
	 $write("IDL\n%x: %x %x %x %x %x %x %x %x %x %x\n", 
		rv.pipe.pc_id, rv.pipe.inst1_id, rv.pipe.rs1_1_id, rv.pipe.rs2_1_id, rv.pipe.rd_1_id, rv.pipe.wr_reg_1_id,
		rv.pipe.inst2_id, rv.pipe.rs1_2_id, rv.pipe.rs2_2_id, rv.pipe.rd_2_id, rv.pipe.wr_reg_2_id);
      end

      //DP_wire
      if (reset) begin
	 $write("DPW\n%x: %x %x %x %x %x %x %x %x; %x %x %x %x %x %x %x %x\n",
		rv.pipe.pc_id, 
		rv.pipe.inst1_id, rv.pipe.src1_1, (~rv.pipe.uses_rs1_1_id | rv.pipe.resolved1_1), 
		rv.pipe.src2_1, (~rv.pipe.uses_rs2_1_id | rv.pipe.resolved2_1), 
		rv.pipe.dst1_renamed, rv.pipe.rs_ent_1_id, rv.pipe.sptag1_id,
		rv.pipe.inst2_id, rv.pipe.src1_2, (~rv.pipe.uses_rs1_2_id | rv.pipe.resolved1_2), 
		rv.pipe.src2_2, (~rv.pipe.uses_rs2_2_id | rv.pipe.resolved2_2), 
		rv.pipe.dst2_renamed, rv.pipe.rs_ent_2_id, rv.pipe.sptag2_id);
      end


      if (reset) begin
	 $write("SOPM1_1 %x %x %x %x %x %x %x %x %x\n",
		rv.pipe.sopm1_1.arfdata, rv.pipe.sopm1_1.arf_busy, rv.pipe.sopm1_1.rrf_valid,
		rv.pipe.sopm1_1.rrftag, rv.pipe.sopm1_1.rrfdata, rv.pipe.sopm1_1.dst1_renamed,
		rv.pipe.sopm1_1.src_eq_0, rv.pipe.sopm1_1.src, rv.pipe.sopm1_1.rdy);
      end

      if (reset) begin
	 $write("SOPM2_1 %x %x %x %x %x %x %x %x %x\n",
		rv.pipe.sopm2_1.arfdata, rv.pipe.sopm2_1.arf_busy, rv.pipe.sopm2_1.rrf_valid,
		rv.pipe.sopm2_1.rrftag, rv.pipe.sopm2_1.rrfdata, rv.pipe.sopm2_1.dst1_renamed,
		rv.pipe.sopm2_1.src_eq_0, rv.pipe.sopm2_1.src, rv.pipe.sopm2_1.rdy);
      end

      if (reset) begin
	 $write("SOPM1_2 %x %x %x %x %x %x %x %x %x\n",
		rv.pipe.sopm1_2.arfdata, rv.pipe.sopm1_2.arf_busy, rv.pipe.sopm1_2.rrf_valid,
		rv.pipe.sopm1_2.rrftag, rv.pipe.sopm1_2.rrfdata, rv.pipe.sopm1_2.dst1_renamed,
		rv.pipe.sopm1_2.src_eq_0, rv.pipe.sopm1_2.src, rv.pipe.sopm1_2.rdy);
      end

      if (reset) begin
	 $write("SOPM2_2 %x %x %x %x %x %x %x %x %x %x\n",
		rv.pipe.sopm2_2.arfdata, rv.pipe.sopm2_2.arf_busy, rv.pipe.sopm2_2.rrf_valid,
		rv.pipe.sopm2_2.rrftag, rv.pipe.sopm2_2.rrfdata, rv.pipe.sopm2_2.dst1_renamed,
		rv.pipe.sopm2_2.src_eq_dst1, rv.pipe.sopm2_2.src_eq_0, rv.pipe.sopm2_2.src, rv.pipe.sopm2_2.rdy);
      end

      //allocate ALU RS_ENT
      if (rv.pipe.req_alunum != 0) begin
	 $write("***ALLOCALU\n%x %x %x %x %x\n",
		rv.pipe.req_alunum, rv.pipe.dst1_renamed, rv.pipe.allocent1_alu, 
		rv.pipe.dst2_renamed, rv.pipe.allocent2_alu);
      end

      //Issue ALU1
      if (rv.pipe.issue_alu1) begin
	 $write("***ISSUEALU1\n%x %x %x %x\n",
		rv.pipe.issueent_alu1, rv.pipe.rrftag_alu1, rv.pipe.ex_src1_alu1, rv.pipe.ex_src2_alu1);
      end

      //Issue ALU2
      if (rv.pipe.issue_alu2) begin
	 $write("***ISSUEALU2\n%x %x %x %x\n",
		rv.pipe.issueent_alu2, rv.pipe.rrftag_alu2, rv.pipe.ex_src1_alu2, rv.pipe.ex_src2_alu2);
	 
      end
      
      //EX Signal ALU1
      if (rv.pipe.robwe_alu1) begin
	 $write("***EXALU1\n%x %x %x %x %x\n",
		rv.pipe.buf_rrftag_alu1, rv.pipe.result_alu1, rv.pipe.rrfwe_alu1,
		rv.pipe.buf_ex_src1_alu1, rv.pipe.buf_ex_src2_alu1);
      end
      
      //EX Signal ALU2
      if (rv.pipe.robwe_alu2) begin
	 $write("***EXALU2\n%x %x %x %x %x\n",
		rv.pipe.buf_rrftag_alu2, rv.pipe.result_alu2, rv.pipe.rrfwe_alu2,
		rv.pipe.buf_ex_src1_alu2, rv.pipe.buf_ex_src2_alu2);
      end

      //allocate LDST RS_ENT
      if (rv.pipe.req_ldstnum != 0 && rv.pipe.allocatable_ldst) begin
	 $write("***ALLOCLDST\n%x %x %x %x %x\n",
		rv.pipe.req_ldstnum, rv.pipe.dst1_renamed, rv.pipe.allocent1_ldst, 
		rv.pipe.dst2_renamed, rv.pipe.allocent2_ldst);
      end

      //Issue LDST
      if (rv.pipe.issue_ldst) begin
	 $write("***ISSUELDST\n%x %x %x %x\n",
		rv.pipe.issueent_ldst, rv.pipe.rrftag_ldst, rv.pipe.ex_src1_ldst, rv.pipe.ex_src2_ldst);
      end

      //EX Signal LDST
      if (rv.pipe.robwe_ldst) begin
	 $write("***EXLDST\n%x READ:%x WRITE:%x ADDR:%x\n RESULT:%x HIT:%x SBDATA:%x\n",
		rv.pipe.buf_rrftag_ldst, rv.pipe.dmem_data, rv.pipe.dmem_wdata,
		rv.pipe.dmem_addr, rv.pipe.seiryu.result, rv.pipe.seiryu.hitsb,
		rv.pipe.seiryu.lddatasb);
      end

      
      //allocate BRANCH RS_ENT
      if (rv.pipe.req_branchnum != 0 && rv.pipe.allocatable_branch) begin
	 $write("***ALLOCBRANCH\n%x %x %x %x %x %x %x\n",
		rv.pipe.req_branchnum, rv.pipe.req1_branch, rv.pipe.req2_branch,
		rv.pipe.dst1_renamed, rv.pipe.allocent1_branch,
		rv.pipe.dst2_renamed, rv.pipe.allocent2_branch);
      end

      //Issue BRANCH
      if (rv.pipe.issue_branch) begin
	 $write("***ISSUEBRANCH\n%x %x %x %x\n",
		rv.pipe.issueent_branch, rv.pipe.rrftag_branch, rv.pipe.ex_src1_branch, rv.pipe.ex_src2_branch);
      end

      //stcommit
      if (rv.pipe.stcommit) begin
	 $write("STCOMMIT!!!\n");
      end

      if (reset) begin
	 $write("BRANCHparam %x %x %x\n", rv.pipe.busyvec_branch, rv.pipe.ready_branch,
		rv.pipe.taggen.brdepth);

	 //RRF_FREELIST_MANAGER
	 $write("RRF_FL %x %x %x %x %x\n",
		rv.pipe.rrf_fl.invalid1, rv.pipe.rrf_fl.invalid2, rv.pipe.rrf_fl.comnum, 
		rv.pipe.rrf_fl.freenum, rv.pipe.rrf_fl.allocatable);

	 $write("RS_LDST\n");

	 $write("0: %x %s %x %x %x %x %x %x\n",
		rv.pipe.reserv_ldst.rrftag_0, rv.pipe.reserv_ldst.dstval_0 ? "LD" : "ST", 
		rv.pipe.reserv_ldst.ex_src1_0, rv.pipe.reserv_ldst.ent0.valid1,
		rv.pipe.reserv_ldst.ex_src2_0, rv.pipe.reserv_ldst.ent0.valid2,
		rv.pipe.reserv_ldst.spectag_0,
		rv.pipe.reserv_ldst.specbitvec[0]);
	 $write("1: %x %s %x %x %x %x %x %x\n",
		rv.pipe.reserv_ldst.rrftag_1, rv.pipe.reserv_ldst.dstval_1 ? "LD" : "ST", 
		rv.pipe.reserv_ldst.ex_src1_1, rv.pipe.reserv_ldst.ent1.valid1,
		rv.pipe.reserv_ldst.ex_src2_1, rv.pipe.reserv_ldst.ent1.valid2,
		rv.pipe.reserv_ldst.spectag_1,
		rv.pipe.reserv_ldst.specbitvec[1]);
	 $write("2: %x %s %x %x %x %x %x %x\n",
		rv.pipe.reserv_ldst.rrftag_2, rv.pipe.reserv_ldst.dstval_2 ? "LD" : "ST", 
		rv.pipe.reserv_ldst.ex_src1_2, rv.pipe.reserv_ldst.ent2.valid1,
		rv.pipe.reserv_ldst.ex_src2_2, rv.pipe.reserv_ldst.ent2.valid2,
		rv.pipe.reserv_ldst.spectag_2,
		rv.pipe.reserv_ldst.specbitvec[2]);
	 $write("3: %x %s %x %x %x %x %x %x\n",
		rv.pipe.reserv_ldst.rrftag_3, rv.pipe.reserv_ldst.dstval_3 ? "LD" : "ST", 
		rv.pipe.reserv_ldst.ex_src1_3, rv.pipe.reserv_ldst.ent3.valid1,
		rv.pipe.reserv_ldst.ex_src2_3, rv.pipe.reserv_ldst.ent3.valid2,
		rv.pipe.reserv_ldst.spectag_3,
		rv.pipe.reserv_ldst.specbitvec[3]);
	 $write("Inv_vector_spec: %x\n", rv.pipe.reserv_ldst.inv_vector_spec);

	 $write("Store Buffer fin: %x com: %x ret: %x\n",
		rv.pipe.sb.finptr, rv.pipe.sb.comptr, rv.pipe.sb.retptr);
	 for (i = 0 ; i < `STBUF_ENT_NUM ; i = i + 1) begin
	    $write("%x: %x %x %x %x %x %x\n", i,
		   rv.pipe.sb.valid[i], rv.pipe.sb.completed[i], rv.pipe.sb.addr[i], rv.pipe.sb.data[i],
		   rv.pipe.sb.specbit[i], rv.pipe.sb.spectag[i]);
	 end
	 
	 $write("MPFT Table %x %x %x %x\n",
		rv.pipe.mpft.setspec1_en, rv.pipe.mpft.setspec1_tag,
		rv.pipe.mpft.setspec2_en, rv.pipe.mpft.setspec2_tag);
	 for (i = 0; i < `SPECTAG_LEN; i = i + 1) begin
	    $write("%d%d%d%d%d %d\n", 
		   rv.pipe.mpft.value4[i], rv.pipe.mpft.value3[i], rv.pipe.mpft.value2[i],
		   rv.pipe.mpft.value1[i], rv.pipe.mpft.value0[i], rv.pipe.mpft_valid[i]);
	 end

	 //RTALL
	  $write("RT ALL\n");
	  for (i = 0; i < `REG_NUM; i = i + 1) begin
	  $write("%x %x; %x %x; %x %x; %x %x; %x %x; %x %x\n",
	  rv.pipe.aregfile.rt.busy_master[i],
	  {rv.pipe.aregfile.rt.tag5_master[i], rv.pipe.aregfile.rt.tag4_master[i],
	  rv.pipe.aregfile.rt.tag3_master[i], rv.pipe.aregfile.rt.tag2_master[i],
	  rv.pipe.aregfile.rt.tag1_master[i], rv.pipe.aregfile.rt.tag0_master[i]},
	  rv.pipe.aregfile.rt.busy_0[i],
	  {rv.pipe.aregfile.rt.tag5_0[i], rv.pipe.aregfile.rt.tag4_0[i],
	  rv.pipe.aregfile.rt.tag3_0[i], rv.pipe.aregfile.rt.tag2_0[i],
	  rv.pipe.aregfile.rt.tag1_0[i], rv.pipe.aregfile.rt.tag0_0[i]},
	  rv.pipe.aregfile.rt.busy_1[i],
	  {rv.pipe.aregfile.rt.tag5_1[i], rv.pipe.aregfile.rt.tag4_1[i],
	  rv.pipe.aregfile.rt.tag3_1[i], rv.pipe.aregfile.rt.tag2_1[i],
	  rv.pipe.aregfile.rt.tag1_1[i], rv.pipe.aregfile.rt.tag0_1[i]},
	  rv.pipe.aregfile.rt.busy_2[i],
	  {rv.pipe.aregfile.rt.tag5_2[i], rv.pipe.aregfile.rt.tag4_2[i],
	  rv.pipe.aregfile.rt.tag3_2[i], rv.pipe.aregfile.rt.tag2_2[i],
	  rv.pipe.aregfile.rt.tag1_2[i], rv.pipe.aregfile.rt.tag0_2[i]},
	  rv.pipe.aregfile.rt.busy_3[i],
	  {rv.pipe.aregfile.rt.tag5_3[i], rv.pipe.aregfile.rt.tag4_3[i],
	  rv.pipe.aregfile.rt.tag3_3[i], rv.pipe.aregfile.rt.tag2_3[i],
	  rv.pipe.aregfile.rt.tag1_3[i], rv.pipe.aregfile.rt.tag0_3[i]},
	  rv.pipe.aregfile.rt.busy_4[i],
	  {rv.pipe.aregfile.rt.tag5_4[i], rv.pipe.aregfile.rt.tag4_4[i],
	  rv.pipe.aregfile.rt.tag3_4[i], rv.pipe.aregfile.rt.tag2_4[i],
	  rv.pipe.aregfile.rt.tag1_4[i], rv.pipe.aregfile.rt.tag0_4[i]});
	 end
	 //ARF
	 $write("ARF\n");
	 for (i=0 ; i<`REG_NUM ; i=i+1) begin
	    $write("%x: %x %x %x%x%x%x%x%x\n", i, rv.pipe.aregfile.regfile.mem[i], 
		   rv.pipe.aregfile.rt.busy_master[i], rv.pipe.aregfile.rt.tag5_master[i],
		   rv.pipe.aregfile.rt.tag4_master[i], rv.pipe.aregfile.rt.tag3_master[i],
		   rv.pipe.aregfile.rt.tag2_master[i], rv.pipe.aregfile.rt.tag1_master[i],
		   rv.pipe.aregfile.rt.tag0_master[i]);
	 end
	  //RRF
	 $write("RRF\n");
	 for (i=0 ; i<`RRF_NUM ; i=i+1) begin
	    $write("%x: %x %x\n", i, rv.pipe.rregfile.valid[i], rv.pipe.rregfile.datarr[i]);
	 end
      end

      if (rv.pipe.prmiss) begin
	 $write("Prmiss! Information\n");
	 $write("PrmissSpecTag: %x\n", rv.pipe.buf_spectag_branch);
	 $write("PrmissRRFTag: %x\n", rv.pipe.buf_rrftag_branch);
	 $write("SpecTagFix: %x\n", rv.pipe.spectagfix);

	 $write("MPFT Table\n");
	  
	 for (i = 0; i < `SPECTAG_LEN; i = i + 1) begin
	    $write("%d%d%d%d%d %d\n", 
		   rv.pipe.mpft.value4[i], rv.pipe.mpft.value3[i], rv.pipe.mpft.value2[i],
		   rv.pipe.mpft.value1[i], rv.pipe.mpft.value0[i], rv.pipe.mpft_valid[i]);
	 end

	 $write("RS_LDST\n");
	 $write("%x %x %x %x %x\n", 
		rv.pipe.reserv_ldst.spectag_0, rv.pipe.reserv_ldst.spectag_1,
		rv.pipe.reserv_ldst.spectag_2, rv.pipe.reserv_ldst.spectag_3,
		rv.pipe.reserv_ldst.inv_vector);

	  $write("ROB\n");
	  for (i = 0; i < `RRF_NUM; i = i + 1) begin
	  $write("%x: %x %x %x %x %x\n", 
	  i, rv.pipe.rob.finish[i], rv.pipe.rob.storebit[i], rv.pipe.rob.dstvalid[i],
	  rv.pipe.rob.brcond[i], rv.pipe.rob.isbranch[i]);
	 end

	  $write("BTB\n");
	  for (i = 0; i < `BTB_IDX_NUM ; i=i+1) begin
	  $write("%x: %x %x %x\n", 
		 i, rv.pipe.pipe_if.brtbl.valid[i],
		 rv.pipe.pipe_if.brtbl.bia.mem[i], rv.pipe.pipe_if.brtbl.bta.mem[i]);
         end

      end

      if (rv.pipe.prsuccess) begin
	 $write("Prsuccess! Information\n");
	 $write("PrsuccessSpecTag: %x\n", rv.pipe.buf_spectag_branch);
	 $write("PrsuccessRRFTag: %x\n", rv.pipe.buf_rrftag_branch);
      end

      //Commit Signal
      if (rv.pipe.comnum > 0 && ~rv.pipe.prmiss) begin
	 $write("***COM1: %x %x %x\n", rv.pipe.comptr, rv.pipe.dstarf1, rv.pipe.com1data);
      end

      if (rv.pipe.comnum > 1 && ~rv.pipe.prmiss) begin
	 $write("***COM2: %x %x %x\n", rv.pipe.comptr2, rv.pipe.dstarf2, rv.pipe.com2data);
      end

      //Simulation I/OMAP****************************************************      
      if (rv.dmem_we && rv.dmem_addr == 32'h0) begin
         $write("\n***\n%c\n***\n", rv.dmem_wdata[7:0]);
      end
      
      
      if (rv.dmem_we && rv.dmem_addr == 32'h4) begin
         $write("%d", rv.dmem_wdata);
      end

      if (rv.dmem_we && rv.dmem_addr == 32'h8) begin
	 $write("\n%d clks\n", CLK_CYCLE);
	 $write("stall: %d stall_by_LDST: %d\n", stall, stall_ldst);
	 $write("stall_by_branch: %d stall_by_prsuccess: %d\n",
		stall_branch, stall_prsuccess);
	 $write("prnum: %d, prsuccess: %d, prmiss: %d\n (prcom: %d)\n", prnum, prsu, prmi, prcom);
	 $finish;
      end    

   end // always @ (posedge clk)

endmodule
