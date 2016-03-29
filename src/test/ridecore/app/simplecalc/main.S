###########################################################################
# Sample Program for MieruEMB System v1.0
###########################################################################
     .text
     .align   2
     .globl   main
main:
	li x1, 1
	li x2, 2
	li x3, -1
	li x4, -2
	li x31, 1000
	li x30, 0
loop:
	addi x30, x30, 1
	#update n
	add x5, x2, x3
	add x5, x5, x4
	sub x5, x5, x1
	add x6, x1, x3
	add x6, x6, x4
	sub x6, x6, x2
	add x7, x1, x2
	add x7, x7, x4
	sub x7, x7, x3
	add x8, x1, x2
	add x8, x8, x3
	sub x8, x8, x4
	mv x1, x5
	mv x2, x6
	mv x3, x7
	mv x4, x8
	#result
	add x10, x5, x6
	add x11, x7, x8
	add x10, x10, x11
	sw x10, 4(x0)
	blt x30, x31, loop
	
finish:
	sw x0, 8(x0)
	j finish
	
	.end     main
