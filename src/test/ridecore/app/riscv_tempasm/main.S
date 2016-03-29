###########################################################################
# Sample Program for MieruEMB System v1.0
###########################################################################
     .text
     .align   2
     .globl   main
#     .ent     main

main:
#     .set     noreorder
	addi x1, x0, 0
	addi x2, x0, 65
	sb x2, 0(x1)          # output

$L1:
	sb x2, 8(x1)          # end
	j     $L1             # while(1)
	.end     main
