`include "constants.vh"
`include "rv32_opcodes.vh"

module testbench();
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
	 rv.pipe.pipe_if.gsh.prhisttbl.pht0.mem[i] = 2;
	 rv.pipe.pipe_if.gsh.prhisttbl.pht1.mem[i] = 2;
      end
      
      fp = $fopen("../bin/init.bin", "rb");
      temp = $fread(rv.instmemory.mem, fp);
      fp = $fopen("../bin/init.bin", "rb");
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
      end
      if (reset && rv.pipe.prsuccess) begin
	 prsu = prsu + 1;
	 prnum = prnum + 1;
      end
      if (reset && rv.pipe.combranch) begin
	 prcom = prcom + 1;
      end
   end

   
   always @ (posedge clk) begin
      //Simulation I/OMAP****************************************************      
      if (rv.dmem_we && rv.dmem_addr == 32'h0) begin
	 $write("%c", rv.dmem_wdata[7:0]);
      end

      if (rv.dmem_we && rv.dmem_addr == 32'h4) begin
         $write("%d", rv.dmem_wdata);
      end

      if (rv.dmem_we && rv.dmem_addr == 32'h8) begin
	 $write("\n%d clks\n", CLK_CYCLE);
	 /*
	 $write("stall: %d stall_by_LDST: %d\n", stall, stall_ldst);
	 $write("stall_by_branch: %d stall_by_prsuccess: %d",
		stall_branch, stall_prsuccess);
	  */
	 $write("prnum: %d, prsuccess: %d, prmiss: %d\n (prcom: %d)\n", prnum, prsu, prmi, prcom);
	 $finish;
      end    

   end // always @ (posedge clk)
endmodule
