# This program uses the instructions defined in the
# basic_microcode.def file. It counts down to 0 from 2
# and stores -1 in memory location 16.
# (c) GPL3 Warren Toomey, 2012
#
# Program za preverjanje, ali je število praštevilo

main:		li r1, 1			# r1 = 1 -> za preverjanje ali je število sploh lahko praštevilo
		li r2, 29			# r2 = X -> poljubno število
		li r3, 2          		# r3 = 2 -> začetni delitelj
		jle r2, r1, notprime		# če je r2 <= 1 potem ni praštevilo
checkdividers:	rem r4, r2, r3    		# r4 = r2 % r3 (ostanek pri deljenju)
		jeqz r4, notprime 		# če je ostanek 0 potem ni praštevilo
		addi r3, r3, 1    		# r3 = r3 + 1 (naslednji delitelj)
		mul r5, r3, r3    		# r5 = r3 * r3 (kvadrat delitelja)
		jle r5, r2, checkdividers	# ponovni skok na začetek zanke, če je kvadrat delitelja <= r2
prime:		li r6, 1         		# r6 = 1 (praštevilo)
		jmp save
notprime:	li r6, 2         		# r6 = 2 (ni praštevilo)
save:		sw r6, 100
end: 		jmp end				# neskončna zanka
