# This program uses the instructions defined in the
# basic_microcode file. 
# (c) Marcel Homšak, 2024

main:	li r0, 21845      # 0101010101010101b
	li r1, 43690      # 1010101010101010b
	li r2, 16384      # začetni naslov
    	li r3, 16399      # končni naslov
	li r4, 0	  # naslovni odmik
	li r5, 0	  # ostanek pri deljenju

loop:	remi r5, r4, 2	  # r5 = naslovni odmik % 2
    	beqz r5, store1
	br store2
	
store1: swri  r0, r2, r4  # shrani vsebino r0 na naslov r2 + r4
	br incr
store2: swri  r1, r2, r4  # shrani vsebino r1 na naslov r2 + r4
	br incr

incr:	inc r4
    	blt r2, r3, loop  # ponavljaj dokler ne pridemo do končnega naslova