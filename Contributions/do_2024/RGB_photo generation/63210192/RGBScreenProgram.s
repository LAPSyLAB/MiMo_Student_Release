# This program uses the instructions defined in the
# basic_microcode.def file.
# (c) GPL3 Warren Toomey, 2012

main: 		li r1, 49152 		# address of the RGB Screen
writepixel:	swi r2, r1, 0		# write a pixel
		jnez r1, writepixel	# loop
