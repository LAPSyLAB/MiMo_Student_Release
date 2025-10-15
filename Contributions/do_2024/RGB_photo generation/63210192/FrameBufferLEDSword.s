# This program uses the instructions defined in the
# basic_microcode file.
# (c) GPL3 Warren Toomey, 2012

main:		li	r1, 16384		# starting row
		li 	r2, 0			# row counter
		li 	r3, 3			# loop counter
		li 	r4, 576			# blade
		li	r5, 8184		# guard
		li 	r6, 960			# top handle part
		li	r7, 384			# handle & tip
handle:		swri	r7, r1, r2		# draw a handle row
		addi 	r2, r2, 1		# next row
		subi	r3, r3, 1		# decrement counter
		jnez	r3, handle		# loop 3 times
tophandle:	swri	r6, r1, r2		# draw the top handle part
		addi 	r2, r2, 1		# next row
guard:		swri	r5, r1, r2		# draw the guard
		addi 	r2, r2, 1		# next row
		li	r3, 10			# reset loop counter
blade:		swri	r4, r1, r2		# draw a handle row
		addi 	r2, r2, 1		# next row
		subi	r3, r3, 1		# decrement counter
		jnez	r3, blade		# loop 10 times
tip:		swri	r7, r1, r2		# draw the swort tip
end:		jnez	r1, end			# infinite loop
		
			