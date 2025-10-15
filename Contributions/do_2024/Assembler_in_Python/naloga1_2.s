main:	li r1, 3   #stevect
        li r2, -1
zanka:  add r1, r1, r2
		jnez r1, zanka #komentar
		li r1, 255
		sw r1, 32