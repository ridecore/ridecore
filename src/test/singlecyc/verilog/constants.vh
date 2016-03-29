//Register File
`define REG_SEL 5
`define REG_NUM 2**`REG_SEL

//Instruction
`define IMM_TYPE_WIDTH 2
`define IMM_I `IMM_TYPE_WIDTH'd0
`define IMM_S `IMM_TYPE_WIDTH'd1
`define IMM_U `IMM_TYPE_WIDTH'd2
`define IMM_J `IMM_TYPE_WIDTH'd3

`define DATA_LEN 32
`define INSN_LEN 32
`define ADDR_LEN 32
`define EXPCODE_LEN 4
`define ISSUE_NUM 2
`define REQDATA_LEN 2

//Re-Order Buffer
`define ROB_SEL 4
`define ROB_NUM 2**`ROB_SEL
`define PRF_SEL `ROB_SEL
`define PRF_NUM 2**`PRF_SEL
`define ROB_RDP_PORT 4
`define ROB_RCOM_PORT 2
`define ROB_WDP_PORT 2
`define ROB_WWB_PORT 2
`define ROB_STATE_PEND 1
`define ROB_STATE_FINISH 0

`define FU_NUM 5

//Rename Table
`define RT_RPREG_PORT 6
`define RT_RVAL_PORT 4
`define RT_RPEND_PORT 4
`define RT_WPREG_PORT 2
`define RT_WVAL_PORT 4
`define RT_WPEND_PORT 4

//PC_selecter
`define PCSEL_LEN 2
`define PCSEL_INCR `PCSEL_LEN'h0
`define PCSEL_JMP `PCSEL_LEN'h1
`define ENTRY_POINT `ADDR_LEN'h200

//Decoder
`define RS_ENT_SEL 5
`define RS_ENT_ALU 1
`define RS_ENT_BRANCH 4
`define RS_ENT_JAL `RS_ENT_BRANCH
`define RS_ENT_JALR `RS_ENT_BRANCH
`define RS_ENT_MUL 5
`define RS_ENT_DIV 6
`define RS_ENT_LD 8
`define RS_ENT_ST 9

//src_a
`define SRC_A_SEL_WIDTH 2
`define SRC_A_RS1  `SRC_A_SEL_WIDTH'd0
`define SRC_A_PC   `SRC_A_SEL_WIDTH'd1
`define SRC_A_ZERO `SRC_A_SEL_WIDTH'd2

//src_b
`define SRC_B_SEL_WIDTH 2
`define SRC_B_RS2  `SRC_B_SEL_WIDTH'd0
`define SRC_B_IMM  `SRC_B_SEL_WIDTH'd1
`define SRC_B_FOUR `SRC_B_SEL_WIDTH'd2
`define SRC_B_ZERO `SRC_B_SEL_WIDTH'd3

/*
`define PC_SRC_SEL_WIDTH 3
`define PC_PLUS_FOUR     `PC_SRC_SEL_WIDTH'd0
`define PC_BRANCH_TARGET `PC_SRC_SEL_WIDTH'd1
`define PC_JAL_TARGET    `PC_SRC_SEL_WIDTH'd2
`define PC_JALR_TARGET   `PC_SRC_SEL_WIDTH'd3
`define PC_REPLAY        `PC_SRC_SEL_WIDTH'd4
`define PC_HANDLER       `PC_SRC_SEL_WIDTH'd5
`define PC_EPC           `PC_SRC_SEL_WIDTH'd6
*/

/*
`define WB_SRC_SEL_WIDTH 2
`define WB_SRC_ALU  `WB_SRC_SEL_WIDTH'd0
`define WB_SRC_MEM  `WB_SRC_SEL_WIDTH'd1
`define WB_SRC_CSR  `WB_SRC_SEL_WIDTH'd2
`define WB_SRC_MD   `WB_SRC_SEL_WIDTH'd3
*/

`define MEM_TYPE_WIDTH 3
`define MEM_TYPE_LB  `MEM_TYPE_WIDTH'd0
`define MEM_TYPE_LH  `MEM_TYPE_WIDTH'd1
`define MEM_TYPE_LW  `MEM_TYPE_WIDTH'd2
`define MEM_TYPE_LD  `MEM_TYPE_WIDTH'd3
`define MEM_TYPE_LBU `MEM_TYPE_WIDTH'd4
`define MEM_TYPE_LHU `MEM_TYPE_WIDTH'd5
`define MEM_TYPE_LWU `MEM_TYPE_WIDTH'd6

`define MEM_TYPE_SB  `MEM_TYPE_WIDTH'd0
`define MEM_TYPE_SH  `MEM_TYPE_WIDTH'd1
`define MEM_TYPE_SW  `MEM_TYPE_WIDTH'd2
`define MEM_TYPE_SD  `MEM_TYPE_WIDTH'd3

`define MD_OP_WIDTH 2
`define MD_OP_MUL `MD_OP_WIDTH'd0
`define MD_OP_DIV `MD_OP_WIDTH'd1
`define MD_OP_REM `MD_OP_WIDTH'd2

`define MD_OUT_SEL_WIDTH 2
`define MD_OUT_LO  `MD_OUT_SEL_WIDTH'd0
`define MD_OUT_HI  `MD_OUT_SEL_WIDTH'd1
`define MD_OUT_REM `MD_OUT_SEL_WIDTH'd2

