# This program uses the instructions defined in the
# basic_microcode.def file.
# (c) Marcel Homšak, 2024
#
main:	li r1, 2  # 0, 1
	li r2, 3  # 2, 3
	li r3, 4  # 4, 5
	li r4, 5  # 6, 7
	li r5, 6  # 8, 9
	li r6, 7  # 10, 11
	lwi r0, r3, 6  # M[r3+6] = M[4+6] = M[a] => r0 <- M[a]
