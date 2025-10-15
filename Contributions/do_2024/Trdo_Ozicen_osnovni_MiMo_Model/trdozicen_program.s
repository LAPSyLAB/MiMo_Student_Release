# This program uses the instructions defined in the
# basic_microcode.def file. It counts down to 0 from 2
# and stores -1 in memory location 16.
# (c) GPL3 Warren Toomey, 2012
#
main:	li r1, 5		#comment
	li r2, 5
	add r1, r1, r2
	li r3, 3
	sub r1, r1, r3
	sw r1, 20
	jnez r4, 01
	jnez r1, 30


