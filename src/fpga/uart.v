/**************************************************************************************************/
/* Many-core processor project Arch Lab.                                               TOKYO TECH */
/**************************************************************************************************/
`default_nettype none
  /**************************************************************************************************/
`include "define.v"
  /**************************************************************************************************/
`define SS_SER_WAIT  'd0       // do not modify this. RS232C deserializer, State WAIT
`define SS_SER_RCV0  'd1       // do not modify this. RS232C deserializer, State Receive0
`define SS_SER_DONE  'd9       // do not modify this. RS232C deserializer, State DONE
  /**************************************************************************************************/
  /*
   module UartTx(CLK, RST_X, DATA, WE, TXD, READY);
   input  wire        CLK, RST_X, WE;
   input  wire [15:0] DATA;
   output reg         TXD, READY;

   reg [18:0]   cmd;
   reg [11:0]   waitnum;
   reg [4:0]    cnt;

   always @(posedge CLK or negedge RST_X) begin
   if(~RST_X) begin
   TXD       <= 1'b1;
   READY     <= 1'b1;
   cmd       <= 19'h7ffff;
   waitnum   <= 0;
   cnt       <= 0;
        end else if( READY ) begin
   TXD       <= 1'b1;
   waitnum   <= 0;
   if( WE )begin
   READY <= 1'b0;
   //cmd   <= {DATA[15:8], 2'b01, DATA[7:0], 1'b0};
   cmd   <= {DATA[15:8], 2'b01, 8'b11111111, 1'b1};
   cnt   <= 20;  // 10
            end
        end else if( waitnum >= `SERIAL_WCNT ) begin
   TXD       <= cmd[0];
   READY     <= (cnt == 1);
   cmd       <= {1'b1, cmd[18:1]};
   waitnum   <= 1;
   cnt       <= cnt - 1;
        end else begin
   waitnum   <= waitnum + 1;
        end
    end
   endmodule
   */

  module UartTx(CLK, RST_X, DATA, WE, TXD, READY);
   input wire  CLK, RST_X, WE;
   input wire [7:0] DATA;
   output reg  TXD, READY;

   reg [8:0]   cmd;
   reg [11:0]  waitnum;
   reg [3:0]   cnt;

   always @(posedge CLK or negedge RST_X) begin
      if(~RST_X) begin
         TXD       <= 1'b1;
         READY     <= 1'b1;
         cmd       <= 9'h1ff;
         waitnum   <= 0;
         cnt       <= 0;
      end else if( READY ) begin
         TXD       <= 1'b1;
         waitnum   <= 0;
         if( WE )begin
            READY <= 1'b0;
            cmd   <= {DATA, 1'b0};
            cnt   <= 10;
         end
      end else if( waitnum >= `SERIAL_WCNT ) begin
         TXD       <= cmd[0];
         READY     <= (cnt == 1);
         cmd       <= {1'b1, cmd[8:1]};
         waitnum   <= 1;
         cnt       <= cnt - 1;
      end else begin
         waitnum   <= waitnum + 1;
      end
   end
endmodule

/**************************************************************************************************/

module TX_FIFO(CLK, RST_X, D_IN, WE, RE, D_OUT, D_EN, RDY, ERR);
   input  wire       CLK, RST_X, WE, RE;
   input  wire [7:0] D_IN;
   output reg [7:0]  D_OUT;
   output reg        D_EN, ERR;
   output wire       RDY;
   
   reg [7:0] 	     mem [0:2048-1]; // FIFO memory
   reg [10:0] 	     head, tail;    // regs for FIFO 
   
   assign RDY = (D_EN==0 && head!=tail);
   
   always @(posedge CLK) begin
      if(~RST_X) begin 
         {D_EN, ERR, head, tail, D_OUT} <= 0;
      end
      else begin            
         if(WE) begin  ///// enqueue
            mem[tail] <= D_IN;
            tail <= tail + 1;
            if(head == (tail + 1)) ERR <= 1; // buffer may full!
         end
         
         if(RE) begin  ///// dequeue   
            D_OUT <= mem[head];
            D_EN  <= 1;
            head <= head + 1;
         end else begin
            D_EN <= 0;
         end
      end
   end
endmodule

/**************************************************************************************************/
/*
 module MultiUartTx(CLK, RST_X, TXD, ERR, 
 DT01, WE01, DT02, WE02, DT03, WE03, DT04, WE04);
 input  wire       CLK, RST_X;
 input  wire [7:0] DT01, DT02, DT03, DT04;
 input  wire       WE01, WE02, WE03, WE04;
 output wire       TXD, ERR;
 
 wire RE01, RE02, RE03, RE04;
 wire [7:0] data01, data02, data03, data04;
 wire en01, en02, en03, en04;
 wire RDY01, RDY02, RDY03, RDY04;
 wire ERR01, ERR02, ERR03, ERR04;
 wire [15:0] data;
 wire en;
 wire TxRdy;

 assign ERR = ERR01 | ERR02 | ERR03 | ERR04;
 assign RE01 = (RDY01 & TxRdy);
 assign RE02 = (RDY02 & TxRdy) & (~RDY01 & ~en01);
 assign RE03 = (RDY03 & TxRdy) & (~RDY01 & ~en01) & (~RDY02 & ~en02);
 assign RE04 = (RDY04 & TxRdy) & (~RDY01 & ~en01) & (~RDY02 & ~en02) & (~RDY03 & ~en03);
 
 assign data = (en01) ? {data01, 8'h30} : 
 (en02) ? {data02, 8'h31} :
 (en03) ? {data03, 8'h32} : {data04, 8'h33};
 assign en = en01 | en02 | en03 | en04;

 TX_FIFO fifo_01(CLK, RST_X, DT01, WE01, RE01, data01, en01, RDY01, ERR01); 
 TX_FIFO fifo_02(CLK, RST_X, DT02, WE02, RE02, data02, en02, RDY02, ERR02); 
 TX_FIFO fifo_03(CLK, RST_X, DT03, WE03, RE03, data03, en03, RDY03, ERR03); 
 TX_FIFO fifo_04(CLK, RST_X, DT04, WE04, RE04, data04, en04, RDY04, ERR04); 
 UartTx send(CLK, RST_X, data, en, TXD, TxRdy);
 endmodule
 */
module SingleUartTx(CLK, RST_X, TXD, ERR, DT01, WE01);
   input  wire       CLK, RST_X;
   input  wire [7:0] DT01;
   input  wire 	     WE01;
   output wire 	     TXD, ERR;
   
   wire 	     RE01;
   wire [7:0] 	     data01;
   wire 	     en01;
   wire 	     RDY01;
   wire 	     ERR01;
   wire 	     TxRdy;

   assign ERR = ERR01;
   assign RE01 = (RDY01 & TxRdy);

   TX_FIFO fifo_01(CLK, RST_X, DT01, WE01, RE01, data01, en01, RDY01, ERR01); 
   UartTx send(CLK, RST_X, data01, en01, TXD, TxRdy);
endmodule


/**************************************************************************************************/

module UartRx(CLK, RST_X, RXD, DATA, EN);
   input  wire       CLK, RST_X, RXD; // clock, reset, RS232C input
   output reg [7:0]  DATA;            // 8bit output data
   output reg        EN;              // 8bit output data enable

   reg [3:0] 	     stage;
   reg [12:0] 	     cnt;             // counter to latch D0, D1, ..., D7
   reg [11:0] 	     cnt_start;       // counter to detect the Start Bit
   wire [12:0] 	     waitcnt;

   assign waitcnt = `SERIAL_WCNT;

   always @(posedge CLK or negedge RST_X)
     if (~RST_X) cnt_start <= 0;
     else        cnt_start <= (RXD) ? 0 : cnt_start + 1;

   always @(posedge CLK or negedge RST_X)
     if(~RST_X) begin
        EN     <= 0;
        stage  <= `SS_SER_WAIT;
        cnt    <= 1;
        DATA   <= 0;
     end else if (stage == `SS_SER_WAIT) begin // detect the Start Bit
        EN <= 0;
        stage <= (cnt_start == (waitcnt >> 1)) ? `SS_SER_RCV0 : stage;
     end else begin
        if (cnt != waitcnt) begin
           cnt <= cnt + 1;
           EN <= 0;
        end else begin // receive 1bit data
           stage  <= (stage == `SS_SER_DONE) ? `SS_SER_WAIT : stage + 1;
           EN     <= (stage == 8)  ? 1 : 0;
           DATA   <= {RXD, DATA[7:1]};
           cnt <= 1;
        end
     end
endmodule

/**************************************************************************************************/
/*
module PLOADER(CLK, RST_X, RXD, ADDR, DATA, WE, DONE1, DONE2);
   input  wire       CLK, RST_X, RXD;
   output reg [31:0] ADDR;
   output reg [31:0] DATA;
   output reg        WE;
   output reg        DONE1; // application program load is done
   output reg        DONE2; // scheduling program load is done

   reg [31:0] 	     waddr; // memory write address

   wire 	     SER_EN;
   wire [7:0] 	     SER_DATA;
   
   UartRx recv(CLK, RST_X, RXD, SER_DATA, SER_EN);

   always @(posedge CLK or negedge RST_X) begin
      if(~RST_X) begin
         {ADDR, DATA, WE, waddr, DONE1, DONE2} <= 0;
      end else begin
         if(DONE2==0 && SER_EN) begin
            //ADDR  <= (waddr<32'h40000) ? waddr : {8'h04, 6'd0, waddr[17:0]};
            ADDR  <= waddr;            
            DATA  <= {SER_DATA, DATA[31:8]};
            WE    <= (waddr[1:0]==3);
            waddr <= waddr + 1;
            if(waddr>=`APP_SIZE) DONE1 <= 1;
         end else begin
            WE <= 0;
            if(waddr>=`APP_SIZE) DONE1 <= 1;
            if(waddr>=`IMG_SIZE) DONE2 <= 1;
         end
      end
   end
endmodule
*/

module PLOADER(CLK, RST_X, RXD, ADDR, DATA, WE_32, WE_128, DONE);
   input  wire       CLK, RST_X, RXD;
   output reg [31:0] ADDR;
   output reg [127:0] DATA;
   output reg        WE_32;
   output reg 	     WE_128;
   output reg        DONE;

   reg [31:0] 	     waddr; // memory write address

   wire 	     SER_EN;
   wire [7:0] 	     SER_DATA;
   
   UartRx recv(CLK, RST_X, RXD, SER_DATA, SER_EN);

   always @(posedge CLK or negedge RST_X) begin
      if(~RST_X) begin
         {ADDR, DATA, WE_32, WE_128, waddr, DONE} <= 0;
      end else begin
         if(DONE==0 && SER_EN) begin
            ADDR   <= waddr;            
            DATA   <= {SER_DATA, DATA[127:8]};
            WE_32  <= (waddr[1:0]==3) ? 1'b1 : 1'b0;
	    WE_128 <= (waddr[3:0]==15) ? 1'b1 : 1'b0;
            waddr <= waddr + 1;
            if(waddr>=`APP_SIZE) DONE <= 1;
         end else begin
            WE_32 <= 0;
	    WE_128 <= 0;
            if(waddr>=`APP_SIZE) DONE <= 1;
         end
      end
   end
endmodule

/**************************************************************************************************/
`default_nettype wire
  /**************************************************************************************************/
