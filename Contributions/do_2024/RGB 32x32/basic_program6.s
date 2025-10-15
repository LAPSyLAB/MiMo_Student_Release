# This program uses the instructions defined in the
# basic_microcode.def file.
# (c) Marcel Homšak, 2024
#
main:	li r1, 10
loop:	addi r1, r1, 1
	br loop
