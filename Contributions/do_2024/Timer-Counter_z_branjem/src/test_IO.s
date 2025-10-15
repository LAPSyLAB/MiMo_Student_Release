main:	li	r1, 64			# r1 is current value (start ASCII char 64 @,A,B,C,D,...)
		li  r5, 999			# counter value
		sw  r5, 49153		# start countdown with start value of 999
		li	r0, 2016		# FB value 2, 13
		sw  r0, 16397		# FB line 13
		sw	r0, 16386		# FB line 2
		li	r0, 4080		# FB value 3, 12
		sw  r0, 16396		# FB line 12
		sw	r0, 16387		# FB line 3
		li	r0, 8184		# FB value 4,11
		sw  r0, 16395		# FB line 11
		sw	r0, 16388		# FB line 4
		li	r0, 16380		# FB value 5-10
		sw  r0, 16394		# FB line 10
		sw	r0, 16389		# FB line 5
		sw  r0, 16393		# FB line 9
		sw	r0, 16390		# FB line 6
		sw  r0, 16392		# FB line 8
		sw	r0, 16391		# FB line 7
loop:	sw	r1, 32768		# Save current value to TTY...	
		addi r1, r1, 1		# r1 ... increment value
		lw   r5, 49153		# load value of countdown
		jnez r5, loop		# loop if r0 != 0
end:	jmp	end				# loop forever