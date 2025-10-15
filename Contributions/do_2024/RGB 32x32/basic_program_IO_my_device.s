# This program uses the instructions defined in the
# basic_microcode file. 
# (c) Marcel Homšak, 2024

main:	li r0, 0
	li r1, 49152     # address of my device
	li r2, 1         # 1 == write
	li r3, 0	 # 0 == clear
	swri r3, r1, r0  # clear display
	
store:	swri r2, r1, r0  # write to display
	br store