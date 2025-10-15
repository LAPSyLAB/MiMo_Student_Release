		li r1, 5
		li r7, 31
		push r1
zanka:	addi r1, r1, -1
		bgez r1, zanka
		pop r3
		move r1, r3
