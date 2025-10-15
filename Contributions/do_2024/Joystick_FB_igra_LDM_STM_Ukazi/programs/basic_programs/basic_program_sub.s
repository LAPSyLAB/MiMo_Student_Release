# This program uses the instructions defined in the
# basic_microcode.def file. It counts down to 0 from 2
# and stores -1 in memory location 16.
# (c) GPL3 Warren Toomey, 2012
#
main:	li	r1, 2			# r1 is the counter
		li	r2, 1			# Used to decrement r1
loop:	sub	r1, r1, r2		# r1--
		jnez  r1, loop		# loop if r1 != 0
		sw	r2, 16			# Save the r2	

