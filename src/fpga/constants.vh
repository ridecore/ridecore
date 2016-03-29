//Register File
`define REG_SEL 5
//`define REG_NUM 2**`REG_SEL
`define REG_NUM 32

//Instruction
`define IMM_TYPE_WIDTH 2
`define IMM_I `IMM_TYPE_WIDTH'd0
`define IMM_S `IMM_TYPE_WIDTH'd1
`define IMM_U `IMM_TYPE_WIDTH'd2
`define IMM_J `IMM_TYPE_WIDTH'd3

//Important Wire
`define DATA_LEN 32
`define INSN_LEN 32
`define ADDR_LEN 32
`define ISSUE_NUM 2
`define ENTRY_POINT `ADDR_LEN'h0
//`define REQDATA_LEN 2

//Decoder
`define RS_ENT_SEL 3
`define RS_ENT_ALU 1
`define RS_ENT_BRANCH 2
`define RS_ENT_JAL `RS_ENT_BRANCH
`define RS_ENT_JALR `RS_ENT_BRANCH
`define RS_ENT_MUL 3
`define RS_ENT_DIV 3
`define RS_ENT_LDST 4

//RS
`define ALU_ENT_SEL 3
`define ALU_ENT_NUM 8
`define BRANCH_ENT_SEL 2
`define BRANCH_ENT_NUM 4
`define LDST_ENT_SEL 2
`define LDST_ENT_NUM 4
//`define LDST_ENT_SEL 3
//`define LDST_ENT_NUM 8
`define MUL_ENT_SEL 1
`define MUL_ENT_NUM 2

//STOREBUFFER
`define STBUF_ENT_SEL 5
`define STBUF_ENT_NUM 32

//BTB
`define BTB_IDX_SEL 9
`define BTB_IDX_NUM 512
//`define BTB_IDX_NUM 2**`BTB_IDX_SEL
//`define BTB_TAG_LEN `ADDR_LEN-3-`BTB_IDX_SEL
`define BTB_TAG_LEN 20

//Gshare
`define GSH_BHR_LEN 10
`define GSH_PHT_SEL 10
`define GSH_PHT_NUM 1024
//`define GSH_PHT_NUM 2**`GSH_PHT_SEL

//TagGenerator

//`define SPECTAG_LEN 1+`BRANCH_ENT_NUM
`define SPECTAG_LEN 5
//`define BRDEPTH_LEN `SPECTAG_LEN
`define BRDEPTH_LEN 5

//Re-Order Buffer
`define ROB_SEL 6
//`define ROB_NUM 2**`ROB_SEL
`define ROB_NUM 64
`define RRF_SEL `ROB_SEL
`define RRF_NUM `ROB_NUM

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

