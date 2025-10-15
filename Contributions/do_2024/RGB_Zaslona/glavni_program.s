# This program uses the instructions defined in the
# basic_microcode file. It adds the numbers from 100
# down to 1 and stores the result in memory location 256.
# (c) GPL3 Warren Toomey, 2012
#
main:		li	r1, 0
		li 	r2, 10
		addi	r1, r1, 5
		subi     r1, r1, -5
		addi 	r1, r1, -5
		subi	r1, r1, 5
		addi	r1, r2, 0
		jeq	r1, r2, naprej
		
		addi 	r1, r2, 100
		
naprej:		addi	r1, r2, -10
		jeq	r1, r2, naprej
		neg 	r1
		neg	r2
		
		addi 	r1, r1, -5
		neg	r1
		addi	r2, r2, 5
		neg	r2
		
		lwi	r3, r1, -2 
