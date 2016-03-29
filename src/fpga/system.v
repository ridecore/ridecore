/**************************************************************************************************/
/* Many-core processor project Arch Lab.                                               TOKYO TECH */
/**************************************************************************************************/
`default_nettype none
/**************************************************************************************************/
`include "define.v"
/**************************************************************************************************/

module CLKGEN_DCM(CLK_IN, CLK_OUT, LOCKED);
    input wire  CLK_IN;
    output wire CLK_OUT, LOCKED;

    wire clk_ibuf;
    wire clk_out;
    wire clk0, clk0_fbuf;

    // input buffer
    IBUFG ibuf (.I(CLK_IN),
                .O(clk_ibuf));
    // output buffer
    BUFG  obuf (.I(clk_out),
                .O(CLK_OUT));
    // feedback buffer
    BUFG  fbuf (.I(clk0),
                .O(clk0_fbuf));

    // dcm instantiation
    DCM_SP dcm (// input
                .CLKIN   (clk_ibuf),
                .RST     (1'b0),
                // output
                .CLKFX   (clk_out),
                .LOCKED  (LOCKED),
                // feedback
                .CLK0    (clk0),
                .CLKFB   (clk0_fbuf), 
                // phase shift
                .PSEN    (1'b0),
                .PSINCDEC(1'b0),
                .PSCLK   (1'b0),
                // digital spread spectrum
                .DSSEN   (1'b0));

    defparam dcm.CLKIN_PERIOD   = `DCM_CLKIN_PERIOD;
    defparam dcm.CLKFX_MULTIPLY = `DCM_CLKFX_MULTIPLY;
    defparam dcm.CLKFX_DIVIDE   = `DCM_CLKFX_DIVIDE;
endmodule

/**************************************************************************************************/

module CLKGEN_MMCM(CLK_IN, CLK_OUT, LOCKED);
    input wire  CLK_IN;
    output wire CLK_OUT, LOCKED;

    wire clk_out;
    wire clkfb, clkfb_fbuf;

    // output buffer
    BUFG  obuf (.I(clk_out),
                .O(CLK_OUT));
    // feedback buffer
    BUFG  fbuf (.I(clkfb),
                .O(clkfb_fbuf));

    MMCME2_ADV mmcm (// input
				     .CLKIN1       (CLK_IN),
				     .CLKIN2       (1'b0),
				     .CLKINSEL     (1'b1),
				     .RST          (1'b0),
				     .PWRDWN       (1'b0),
				  	 // output
				     .CLKOUT0      (clk_out),
				     .CLKOUT0B     (),
				     .CLKOUT1      (),
				     .CLKOUT1B     (),
				     .CLKOUT2      (),
				     .CLKOUT2B     (),
				     .CLKOUT3      (),
				     .CLKOUT3B     (),
				     .CLKOUT4      (),
				     .CLKOUT5      (),
				     .CLKOUT6      (),
				     .LOCKED       (LOCKED),
                     // feedback
				     .CLKFBOUT     (clkfb),
				     .CLKFBIN      (clkfb_fbuf),
				     .CLKFBOUTB    (),
				     // dynamic reconfiguration
				     .DADDR        (7'h0),
				     .DI           (16'h0),
				     .DWE          (1'b0),
				     .DEN          (1'b0),
				     .DCLK         (1'b0),
				     .DO           (),
				     .DRDY         (),
				     // phase shift
				     .PSCLK        (1'b0),
				     .PSEN         (1'b0),
				     .PSINCDEC     (1'b0),
				     .PSDONE       (),
				     // status
				     .CLKINSTOPPED (),
				     .CLKFBSTOPPED ());

    defparam mmcm.CLKIN1_PERIOD    = `MMCM_CLKIN1_PERIOD;
    defparam mmcm.CLKFBOUT_MULT_F  = `MMCM_VCO_MULTIPLY;
    defparam mmcm.DIVCLK_DIVIDE    = `MMCM_VCO_DIVIDE;
    defparam mmcm.CLKOUT0_DIVIDE_F = `MMCM_CLKOUT0_DIVIDE;
    defparam mmcm.CLKOUT1_DIVIDE   = `MMCM_CLKOUT1_DIVIDE;
endmodule

/**************************************************************************************************/

module RSTGEN(CLK, RST_X_I, RST_X_O);
    input wire  CLK, RST_X_I;
    output wire RST_X_O;

    reg [7:0] cnt;
    assign RST_X_O = cnt[7];

    always @(posedge CLK or negedge RST_X_I) begin
        if      (!RST_X_I) cnt <= 0;
        else if (~RST_X_O) cnt <= (cnt + 1'b1);
    end
endmodule

/**************************************************************************************************/

module GEN_DCM(CLK_I, RST_X_I, CLK_O, RST_X_O);
    input wire  CLK_I, RST_X_I;
    output wire CLK_O, RST_X_O;
    
    wire LOCKED;
    
    CLKGEN_DCM clkgen(.CLK_IN (CLK_I),
                      .CLK_OUT(CLK_O),
                      .LOCKED (LOCKED));
    RSTGEN     rstgen(.CLK    (CLK_O),
                      .RST_X_I(RST_X_I & LOCKED),
                      .RST_X_O(RST_X_O));
endmodule

module GEN_MMCM(CLK_I, RST_X_I, CLK_O, RST_X_O);
    input wire  CLK_I, RST_X_I;
    output wire CLK_O, RST_X_O;
    
    wire clk_ibuf;
    wire LOCKED;

    // input buffer
    IBUFG ibuf (.I(CLK_I),
                .O(clk_ibuf));

    CLKGEN_MMCM clkgen(.CLK_IN (clk_ibuf),
                       .CLK_OUT(CLK_O),
                       .LOCKED (LOCKED));
    RSTGEN      rstgen(.CLK    (CLK_O),
                       .RST_X_I(RST_X_I & LOCKED),
                       .RST_X_O(RST_X_O));
endmodule

module GEN_MMCM_DS(CLK_P, CLK_N, RST_X_I, CLK_O, RST_X_O);
    input wire  CLK_P, CLK_N, RST_X_I;
    output wire CLK_O, RST_X_O;

    wire clk_ibuf;
    wire LOCKED;

    // input buffer
    IBUFGDS ibuf (.I (CLK_P),
                  .IB(CLK_N),
                  .O (clk_ibuf));

    CLKGEN_MMCM clkgen(.CLK_IN (clk_ibuf),
                       .CLK_OUT(CLK_O),
                       .LOCKED (LOCKED));
    RSTGEN      rstgen(.CLK    (CLK_O),
                       .RST_X_I(RST_X_I & LOCKED),
                       .RST_X_O(RST_X_O));
endmodule

/**************************************************************************************************/
`default_nettype wire
/**************************************************************************************************/
