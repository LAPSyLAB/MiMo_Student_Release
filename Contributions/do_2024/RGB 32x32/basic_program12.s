# This program uses the instructions defined in the
# basic_microcode.def file.
# (c) Marcel Homšak, 2024
#
main:	li r1, 7
	li r2, 4
	swi r1, r2, 6  # M[r2+6] = r1 => M[a] = 7