#for y in 0..127:
#    for x in 0..127:
#        red   = x >> 2         // 5-bit red
#        green = y >> 1         // 6-bit green
#        blue  = (x + y) >> 3   // 5-bit blue
#
#        color = (red << 11) | (green << 5) | blue
#        address = 0xC000 | (y << 7) | x
#
#        memory[address] = color
		
		# Clear registers
		li r0, 0	# r0 - X
		li r1, 0	# r1 - Y
		li r2, 0	# r2 - Red
		li r3, 0	# r3 - Green
		li r4, 0	# r4 - Blue
		li r5, 0	# r5 - Combined Color (	Value to save)
		li r6, 0xC000	# r6 - Screen address (starts at C000)
		li r7, 0	# r7 - TEMP
		
		
#Y LOOP
y_loop:	li r0, 0 # reset X to start of line
		
#X LOOP		
x_loop:	li r6, 0xC000 # reset address
		li r5, 0	# reset color
		
		
		# Scale X then write to red
		lsri r2, r0, 2
		lsli r2, r2, 11
		# Scale Y then write to green
		lsri r3, r1, 1
		lsli r3, r3, 5
		# Add X and Y into blue, scale down
		add r4, r0, r1
		lsri r4, r4, 3
		li r7, 31
		sub r4, r7, r4
		
		# OR all the colors into the color register
		or r5, r5, r2 #R
		or r5, r5, r3 #G
		or r5, r5, r4 #B
		# get the address (could technically just increment it every loop but this way i can reuse the code later)
		lsli r7, r1, 7	# shift Y and save to TEMP
		or r6, r6, r7	# OR Y into address
		#or r6, r6, r0	# OR X into address
		
		# Save r5 to r6 + r1, in theory saves a cycle from no loading immediate
		swri r5, r6, r0	# swri Rd,Rs,Rt   M[Rs+Rt] <- Rd		PC <- PC + 1
		
	li r7, 127	# Set loop limit
	inc r0	# X++
	jle r0, r7, x_loop # if x < 127 goto x_loop
	inc r1	# Y++
	jle r1, r7, y_loop # else if y < 127 goto y_loop

_end: br _end