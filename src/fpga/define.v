/**************************************************************************************************/
/* Many-core processor project Arch Lab.                                               TOKYO TECH */
/**************************************************************************************************/
//`default_nettype none
/**************************************************************************************************/

/* Clock Frequency Definition                                                                     */
/* Clock Freq = (System Clock Freq) * (DCM_CLKFX_MULTIPLY) / (DCM_CLKFX_DIVIDE)                   */
/**************************************************************************************************/
`define SYSTEM_CLOCK_FREQ   200    // Atlys -> 100 MHz, Nexys4 -> 100 MHz, Virtex7 -> 200 MHz

`define DCM_CLKIN_PERIOD    5.000  // Atlys -> 10.000 ns
`define DCM_CLKFX_MULTIPLY  3      // CLKFX_MULTIPLY must be 2~32
`define DCM_CLKFX_DIVIDE    25     // CLKFX_DIVIDE   must be 1~32

`define MMCM_CLKIN1_PERIOD  5.000  // Nexys4 -> 10.000 ns, Virtex7 -> 5.000 ns
`define MMCM_VCO_MULTIPLY   8      // for VCO, 800-1600
`define MMCM_VCO_DIVIDE     2
`define MMCM_CLKOUT0_DIVIDE 16     // for user clock, 50  MHz
`define MMCM_CLKOUT1_DIVIDE 4      // for dram clock, 200 MHz


/* UART Definition                                                                                */
/**************************************************************************************************/
`define SERIAL_WCNT  'd50       // 24MHz/1.5Mbaud, parameter for UartRx and UartTx
`define APP_SIZE        8*1024  // application program load size in byte (64*16=1024KB)
`define SCD_SIZE       64*1024  // scheduling program  load size in byte (64* 1=  64KB)
`define IMG_SIZE     1088*1024  // full image file     load size in byte (64*17=1088KB)


/**************************************************************************************************/
//`default_nettype wire
/**************************************************************************************************/
