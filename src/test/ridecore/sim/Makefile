MD = ../../../fpga
SIMDIR = .
OBJS = $(MD)/alloc_issue_ino.v \
$(MD)/alu.v \
$(MD)/arf.v \
$(MD)/brimm_gen.v \
$(MD)/btb.v \
$(MD)/decoder.v \
$(MD)/dmem.v \
$(MD)/dualport_ram.v \
$(MD)/exunit_alu.v \
$(MD)/exunit_branch.v \
$(MD)/exunit_ldst.v \
$(MD)/exunit_mul.v \
$(MD)/gshare.v \
$(MD)/imem.v \
$(MD)/imem_outa.v \
$(MD)/imm_gen.v \
$(MD)/mpft.v \
$(MD)/multiplier.v \
$(MD)/pipeline_if.v \
$(MD)/pipeline.v \
$(MD)/prioenc.v \
$(MD)/ram_sync_nolatch.v \
$(MD)/ram_sync.v \
$(MD)/reorderbuf.v \
$(MD)/rrf_freelistmanager.v \
$(MD)/rrf.v \
$(MD)/rs_alu.v \
$(MD)/rs_branch.v \
$(MD)/rs_ldst.v \
$(MD)/rs_mul.v \
$(MD)/rs_reqgen.v \
$(MD)/src_manager.v \
$(MD)/srcopr_manager.v \
$(MD)/srcsel.v \
$(MD)/tag_generator.v \
$(MD)/oldest_finder.v \
$(MD)/storebuf.v \
$(MD)/search_be.v \
$(MD)/topsim.v

OBJDBG = $(SIMDIR)/testbench.v
OBJLST = $(SIMDIR)/testbench_last.v
OBJPRD = $(SIMDIR)/testbench_pred.v
SIMOP1 = -full64
SIMOP2 = -v2005

a.out: $(OBJS) $(OBJDBG)
	iverilog -Wall -I $(MD) $(OBJS) $(OBJLST)

last: $(OBJS) $(OBJLST)
	iverilog -Wall -I $(MD) $(OBJS) $(OBJLST)

dbg: $(OBJS) $(OBJDBG)
	iverilog -Wall -I $(MD) $(OBJS) $(OBJDBG)

pr: $(OBJS) $(OBJPRD)
	iverilog -Wall -I $(MD) $(OBJS) $(OBJPRD)

lastvcs: $(OBJS) $(OBJLST)
	vcs +lint=all $(SIMOP1) $(SIMOP2) $(OBJS) $(OBJLST)

dbgvcs: $(OBJS) $(OBJDBG)
	vcs $(SIMOP1) $(SIMOP2) $(OBJS) $(OBJDBG)

prvcs: $(OBJS) $(OBJPRD)
	vcs $(SIMOP1) $(SIMOP2) $(OBJS) $(OBJPRD)
