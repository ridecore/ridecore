MD = ../verilog
OBJS = $(MD)/decoder.v \
$(MD)/imm_gen.v \
$(MD)/ram_sync.v \
$(MD)/ram_sync_nolatch.v \
$(MD)/srcsel.v \
$(MD)/alu.v \
$(MD)/multiplier.v \
$(MD)/memory.v

OBJDBG = $(MD)/singlecycproc.v
OBJLST = $(MD)/singlecycproc_last.v
OBJCOM = $(MD)/singlecycproc_com.v
OBJCOMRF = $(MD)/singlecycproc_comrf.v

a.out: $(OBJS) $(OBJDBG)
	iverilog -I $(MD) $(OBJS) $(OBJDBG)

dbg: $(OBJS) $(OBJDBG)
	iverilog -I $(MD) $(OBJS) $(OBJDBG)

lst: $(OBJS) $(OBJLST)
	iverilog -I $(MD) $(OBJS) $(OBJLST)

com: $(OBJS) $(OBJCOM)
	iverilog -I $(MD) $(OBJS) $(OBJCOM)

comrf: $(OBJS) $(OBJCOMRF)
	iverilog -I $(MD) $(OBJS) $(OBJCOMRF)

sim: a.out
	./a.out

