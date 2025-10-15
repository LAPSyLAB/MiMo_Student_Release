# This program uses the instructions defined in the
# basic_microcode.def file.
# (c) Marcel Homšak, 2024
#
main:	li	r1, 2
	li	r2, 5
	mul	r1, r1, r2
	sw	r1, 16
