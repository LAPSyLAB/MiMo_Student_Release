# =================================================#
# 			Lestvica (Od C4 do C5)				   #			
# (c) Mitja Kocjančič, 13.12.2020 16:20 PM		   #
# =================================================#
#                                                  #
#  			Ču se je oženil: 	                   #
# {Note | Velocity | Stevilo ponavljanj} //Nota    #
# {60   | 1        | 1                 } //C       #
# {62   | 1        | 1                 } //D       #
# {64   | 1        | 1                 } //E       #
# {65   | 1        | 1                 } //F       #
# {67   | 1        | 1                 } //G       #
# {69   | 1        | 1                 } //A	   #
# {70   | 1        | 1                 } //H       #
# {71   | 1        | 1                 } //C 	   #     
#==================================================#

main:	li r0, 27			# r0 is the main loop counter (Pesmica je dolga 27 taktov)

		li r1, 1			# Used to RESET Speaker 
		
	
loop:	li r2, 60			# Note (C)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		
		li r2, 62			# Note (D)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		

		li r2, 64			# Note (E)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		
		li r2, 65			# Note (F)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		
		li r2, 67			# Note (G)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
	
		li r2, 69			# Note (A)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		
		li r2, 71			# Note (H)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		
		li r2, 72			# Note (C)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity

jnez	r0, loop			# loop if r0 != 0

#Speaker parameters
#49152 = Speaker RESET
#49153 = Note
#49154 = Note Velocity