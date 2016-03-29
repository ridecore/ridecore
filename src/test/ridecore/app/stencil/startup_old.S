###########################################################################
# Sample Program for MieruEMB System v1.0            Arch Lab. TOKYO TECH #
###########################################################################
	.text
	.globl  _start
#     .ent    _start
_start:
#     .set    noreorder
#     .set    noat

	nop
	
	li $sp, 0x7ff00   # stack pointer 512KB
	j      main       # jump to the main
	nop

	.end _start
