main:	li r0, 125
		li r7, 0x1000
		divi r0, r0, 5
		jsr skip
		li r4, 9999
		
skip:	li r1, -16
		li r2, -4
		beq r1, r2, end
		asri r1, r1, 2

end: 	beq r1, r2, end
		
		