# ==============================================#
# 			I play note C forever				#			
# (c) Mitja Kocjančič, 13.12.2020 03:20 AM		#
# ==============================================#

main:	li r0, 2			# r0 is the main loop counter
		li r1, 1			# Used to RESET Speaker 
		li r2, 60			# Note (C)
		li r3, 127			# Note Velocity
		li r4, 1			# Number of repetitions
		
		
loop:	sw  r1, 49152 		# RESET Speaker (should beep)
		sw  r2, 49153 		# Set Note to C
		sw	r3, 49154		# Set Note Velocity to 127
jnez	r0, loop			# loop if r0 != 0

#Speaker parameters
#49152 = Speaker RESET
#49153 = Note
#49154 = Note Velocity