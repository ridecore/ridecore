`include "constants.vh"

/*
 size: 
 sb,lb->0
 sh,lh->1
 sw,lw->2 
 */
`define SIZE_REQ_BYTE 0
`define SIZE_REQ_HALF 1
`define SIZE_REQ_WORD 2

module memory(
	      input 		     clk,
	      input [`ADDR_LEN-1:0]  iraddr1,
	      input [`ADDR_LEN-1:0]  iraddr2,
	      input [`ADDR_LEN-1:0]  draddr1,
	      input [`ADDR_LEN-1:0]  draddr2,
	      output [`DATA_LEN-1:0] irdata1,
	      output [`DATA_LEN-1:0] irdata2,
	      output [`DATA_LEN-1:0] drdata1,
	      output [`DATA_LEN-1:0] drdata2,
	      input [1:0] 	     drsize1,
	      input [1:0] 	     drsize2,
	      input [`ADDR_LEN-1:0]  dwaddr1,
	      input [`ADDR_LEN-1:0]  dwaddr2,
	      input [`DATA_LEN-1:0]  dwdata1,
	      input [`DATA_LEN-1:0]  dwdata2,
	      input 		     dwe1,
	      input 		     dwe2,
	      input [1:0] 	     dwsize1,
	      input [1:0] 	     dwsize2
	      );


   wire [`DATA_LEN-1:0] 	     drdata1_ram;
   wire [`DATA_LEN-1:0] 	     drdata2_ram;
   wire [`DATA_LEN-1:0] 	     dwdata1_ram;
   wire [`DATA_LEN-1:0] 	     dwdata2_ram;

   assign drdata1 =
		   (drsize1 == `SIZE_REQ_WORD) ? drdata1_ram :
		   (drsize1 == `SIZE_REQ_HALF) ? 
		   (drdata1_ram >> (`DATA_LEN>>1)*draddr1[1]) :
		   (drsize1 == `SIZE_REQ_BYTE) ?
		   (drdata1_ram >> (`DATA_LEN>>2)*draddr1[1:0]) : 32'h0;
   
   assign drdata2 =
		   (drsize2 == `SIZE_REQ_WORD) ? drdata2_ram :
		   (drsize2 == `SIZE_REQ_HALF) ? 
		   (drdata2_ram >> (`DATA_LEN>>1)*draddr2[1]) :
		   (drsize2 == `SIZE_REQ_BYTE) ?
		   (drdata2_ram >> (`DATA_LEN>>2)*draddr2[1:0]) : 32'h0;

   assign dwdata1_ram =
		       (dwsize1 == `SIZE_REQ_WORD) ? dwdata1 :
		       (dwsize1 == `SIZE_REQ_HALF) ?
		       (
			(dwaddr1[1] == 1'b0) ? 
			{mainmemory.mem0.mem[dwaddr1>>2][31:16], dwdata1[15:0]} :
			{dwdata1[15:0], mainmemory.mem0.mem[dwaddr1>>2][31:16]}
			) :
		       (dwsize1 == `SIZE_REQ_BYTE) ?
		       (
			(dwaddr1[1:0] == 2'b00) ?
			{mainmemory.mem0.mem[dwaddr1>>2][31:8], dwdata1[7:0]} :
			(dwaddr1[1:0] == 2'b01) ?
			{mainmemory.mem0.mem[dwaddr1>>2][31:16], dwdata1[7:0],
			 mainmemory.mem0.mem[dwaddr1>>2][7:0]} :
			(dwaddr1[1:0] == 2'b10) ?
			{mainmemory.mem0.mem[dwaddr1>>2][31:24], dwdata1[7:0],
			 mainmemory.mem0.mem[dwaddr1>>2][15:0]} :
			{dwdata1[7:0], mainmemory.mem0.mem[dwaddr1>>2][23:0]}
			) : 32'h0;

   assign dwdata2_ram =
		       (dwsize2 == `SIZE_REQ_WORD) ? dwdata2 :
		       (dwsize2 == `SIZE_REQ_HALF) ?
		       (
			(dwaddr2[1] == 1'b0) ? 
			{mainmemory.mem0.mem[dwaddr2>>2][31:16], dwdata2[15:0]} :
			{dwdata2[15:0], mainmemory.mem0.mem[dwaddr2>>2][31:16]}
			) :
		       (dwsize2 == `SIZE_REQ_BYTE) ?
		       (
			(dwaddr2[1:0] == 2'b00) ?
			{mainmemory.mem0.mem[dwaddr2>>2][31:8], dwdata2[7:0]} :
			(dwaddr2[1:0] == 2'b01) ?
			{mainmemory.mem0.mem[dwaddr2>>2][31:16], dwdata2[7:0],
			 mainmemory.mem0.mem[dwaddr2>>2][7:0]} :
			(dwaddr2[1:0] == 2'b10) ?
			{mainmemory.mem0.mem[dwaddr2>>2][31:24], dwdata2[7:0],
			 mainmemory.mem0.mem[dwaddr2>>2][15:0]} :
			{dwdata2[7:0], mainmemory.mem0.mem[dwaddr2>>2][23:0]}
			) : 32'h0;
   
   
   //512KB 4READ-2WRITE RAM
   ram_sync_4r2w #(`ADDR_LEN, `DATA_LEN, 131072)
   mainmemory(
	      .clk(clk),
	      .raddr1(iraddr1>>2),
	      .raddr2(iraddr2>>2),
	      .raddr3(draddr1>>2),
	      .raddr4(draddr2>>2),
	      .rdata1(irdata1),
	      .rdata2(irdata2),
	      .rdata3(drdata1_ram),
	      .rdata4(drdata2_ram),
	      .waddr1(dwaddr1>>2),
	      .waddr2(dwaddr2>>2),
	      .wdata1(dwdata1_ram),
	      .wdata2(dwdata2_ram),
	      .we1(dwe1),
	      .we2(dwe2)
	      );
   
endmodule // memory

module memory_nolatch(
		      input 		     clk,
		      input [`ADDR_LEN-1:0]  iraddr1,
		      input [`ADDR_LEN-1:0]  iraddr2,
		      input [`ADDR_LEN-1:0]  draddr1,
		      input [`ADDR_LEN-1:0]  draddr2,
		      output [`DATA_LEN-1:0] irdata1,
		      output [`DATA_LEN-1:0] irdata2,
		      output [`DATA_LEN-1:0] drdata1,
		      output [`DATA_LEN-1:0] drdata2,
		      input [1:0] 	     drsize1,
		      input [1:0] 	     drsize2,
		      input [`ADDR_LEN-1:0]  dwaddr1,
		      input [`ADDR_LEN-1:0]  dwaddr2,
		      input [`DATA_LEN-1:0]  dwdata1,
		      input [`DATA_LEN-1:0]  dwdata2,
		      input 		     dwe1,
		      input 		     dwe2,
		      input [1:0] 	     dwsize1,
		      input [1:0] 	     dwsize2
		      );
   

   wire [`DATA_LEN-1:0] 		     drdata1_ram;
   wire [`DATA_LEN-1:0] 		     drdata2_ram;
   wire [`DATA_LEN-1:0] 		     dwdata1_ram;
   wire [`DATA_LEN-1:0] 		     dwdata2_ram;

   assign drdata1 =
		   (drsize1 == `SIZE_REQ_WORD) ? drdata1_ram :
		   (drsize1 == `SIZE_REQ_HALF) ? 
		   (drdata1_ram >> (`DATA_LEN>>1)*draddr1[1]) :
		   (drsize1 == `SIZE_REQ_BYTE) ?
		   (drdata1_ram >> (`DATA_LEN>>2)*draddr1[1:0]) : 32'h0;
   
   assign drdata2 =
		   (drsize2 == `SIZE_REQ_WORD) ? drdata2_ram :
		   (drsize2 == `SIZE_REQ_HALF) ? 
		   (drdata2_ram >> (`DATA_LEN>>1)*draddr2[1]) :
		   (drsize2 == `SIZE_REQ_BYTE) ?
		   (drdata2_ram >> (`DATA_LEN>>2)*draddr2[1:0]) : 32'h0;

   assign dwdata1_ram =
		       (dwsize1 == `SIZE_REQ_WORD) ? dwdata1 :
		       (dwsize1 == `SIZE_REQ_HALF) ?
		       (
			(dwaddr1[1] == 1'b0) ? 
			{mainmemory.mem0.mem[dwaddr1>>2][31:16], dwdata1[15:0]} :
			{dwdata1[15:0], mainmemory.mem0.mem[dwaddr1>>2][31:16]}
			) :
		       (dwsize1 == `SIZE_REQ_BYTE) ?
		       (
			(dwaddr1[1:0] == 2'b00) ?
			{mainmemory.mem0.mem[dwaddr1>>2][31:8], dwdata1[7:0]} :
			(dwaddr1[1:0] == 2'b01) ?
			{mainmemory.mem0.mem[dwaddr1>>2][31:16], dwdata1[7:0],
			 mainmemory.mem0.mem[dwaddr1>>2][7:0]} :
			(dwaddr1[1:0] == 2'b10) ?
			{mainmemory.mem0.mem[dwaddr1>>2][31:24], dwdata1[7:0],
			 mainmemory.mem0.mem[dwaddr1>>2][15:0]} :
			{dwdata1[7:0], mainmemory.mem0.mem[dwaddr1>>2][23:0]}
			) : 32'h0;

   assign dwdata2_ram =
		       (dwsize2 == `SIZE_REQ_WORD) ? dwdata2 :
		       (dwsize2 == `SIZE_REQ_HALF) ?
		       (
			(dwaddr2[1] == 1'b0) ? 
			{mainmemory.mem0.mem[dwaddr2>>2][31:16], dwdata2[15:0]} :
			{dwdata2[15:0], mainmemory.mem0.mem[dwaddr2>>2][31:16]}
			) :
		       (dwsize2 == `SIZE_REQ_BYTE) ?
		       (
			(dwaddr2[1:0] == 2'b00) ?
			{mainmemory.mem0.mem[dwaddr2>>2][31:8], dwdata2[7:0]} :
			(dwaddr2[1:0] == 2'b01) ?
			{mainmemory.mem0.mem[dwaddr2>>2][31:16], dwdata2[7:0],
			 mainmemory.mem0.mem[dwaddr2>>2][7:0]} :
			(dwaddr2[1:0] == 2'b10) ?
			{mainmemory.mem0.mem[dwaddr2>>2][31:24], dwdata2[7:0],
			 mainmemory.mem0.mem[dwaddr2>>2][15:0]} :
			{dwdata2[7:0], mainmemory.mem0.mem[dwaddr2>>2][23:0]}
			) : 32'h0;
   
   
   //512KB 4READ-2WRITE RAM
   ram_sync_nolatch_4r2w #(`ADDR_LEN, `DATA_LEN, 131072)
   mainmemory(
	      .clk(clk),
	      .raddr1(iraddr1>>2),
	      .raddr2(iraddr2>>2),
	      .raddr3(draddr1>>2),
	      .raddr4(draddr2>>2),
	      .rdata1(irdata1),
	      .rdata2(irdata2),
	      .rdata3(drdata1_ram),
	      .rdata4(drdata2_ram),
	      .waddr1(dwaddr1>>2),
	      .waddr2(dwaddr2>>2),
	      .wdata1(dwdata1_ram),
	      .wdata2(dwdata2_ram),
	      .we1(dwe1),
	      .we2(dwe2)
	      );
   
endmodule // memory_nolatch



