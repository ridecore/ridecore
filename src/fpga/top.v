`include "define.v"
`include "constants.vh"

module top
  (
   input 	    CLK_P,
   input 	    CLK_N,
   input 	    RST_X_IN,
   output 	    TXD,
   input 	    RXD,
   output reg [7:0] LED
   );

   //Active Low SW
   wire 	    clk;
   wire 	    reset_x;


   wire [`ADDR_LEN-1:0] pc;
   wire [4*`INSN_LEN-1:0] idata;
   wire [8:0] 		  imem_addr;
   wire [`DATA_LEN-1:0]   dmem_data;
   wire [`DATA_LEN-1:0]   dmem_wdata;
   wire [`ADDR_LEN-1:0]   dmem_addr;
   wire 		  dmem_we;
   wire [`DATA_LEN-1:0]   dmem_wdata_core;
   wire [`ADDR_LEN-1:0]   dmem_addr_core;
   wire 		  dmem_we_core;

   wire 		  utx_we;
   wire 		  finish_we;
   reg 			  finished;
   wire 		  ready_tx;
   wire 		  loaded;
   
   reg 			  prog_loading;
   wire [4*`INSN_LEN-1:0] prog_loaddata;
   wire [`ADDR_LEN-1:0]   prog_loadaddr;
   wire 		  prog_dmem_we;
   wire 		  prog_imem_we;
   
   assign utx_we = (~finished && dmem_we_core && (dmem_addr_core == 32'h0)) ? 1'b1 : 1'b0;
   assign finish_we = (dmem_we_core && (dmem_addr_core == 32'h8)) ? 1'b1 : 1'b0;
   
   always @ (posedge clk) begin
      if (!reset_x) begin
	 LED <= 0;
      end else if (utx_we) begin
	 LED <= {LED[7], dmem_wdata[6:0]};
      end else if (finish_we) begin
	 LED <= {1'b1, LED[6:0]};
      end
   end

   always @ (posedge clk) begin
      if (!reset_x) begin
	 prog_loading <= 1'b1;
      end else begin
	 prog_loading <= ~loaded;
      end
   end

   always @ (posedge clk) begin
      if (!reset_x) begin
	 finished <= 0;
      end else if (finish_we) begin
	 finished <= 1;
      end
   end
   
   GEN_MMCM_DS genmmcmds
     (
      .CLK_P(CLK_P), 
      .CLK_N(CLK_N), 
      .RST_X_I(~RST_X_IN), 
      .CLK_O(clk), 
      .RST_X_O(reset_x)
      );

   pipeline pipe
     (
      .clk(clk),
      .reset(~reset_x | prog_loading),
      .pc(pc),
      .idata(idata),
      .dmem_wdata(dmem_wdata_core),
      .dmem_addr(dmem_addr_core),
      .dmem_we(dmem_we_core),
      .dmem_data(dmem_data)
      );

   assign dmem_addr = prog_loading ? prog_loadaddr : dmem_addr_core;
   assign dmem_we = prog_loading ? prog_dmem_we : dmem_we_core;
   assign dmem_wdata = prog_loading ? prog_loaddata[127:96] : dmem_wdata_core;
   dmem datamemory(
		   .clk(clk),
		   .addr({2'b0, dmem_addr[`ADDR_LEN-1:2]}),
		   .wdata(dmem_wdata),
		   .we(dmem_we),
		   .rdata(dmem_data)
		   );

   assign imem_addr = prog_loading ? prog_loadaddr[12:4] : pc[12:4];
   imem_ld instmemory(
		      .clk(~clk),
		      .addr(imem_addr),
		      .rdata(idata),
		      .wdata(prog_loaddata),
		      .we(prog_imem_we)
		      );
   
   SingleUartTx sutx
     (
      .CLK(clk),
      .RST_X(reset_x),
      .TXD(TXD),
      .ERR(),
      .DT01(dmem_wdata[7:0]),
      .WE01(utx_we)
      );

   PLOADER loader
     (
      .CLK(clk),
      .RST_X(reset_x),
      .RXD(RXD),
      .ADDR(prog_loadaddr),
      .DATA(prog_loaddata),
      .WE_32(prog_dmem_we),
      .WE_128(prog_imem_we),
      .DONE(loaded)
      );
   
endmodule // top

   
