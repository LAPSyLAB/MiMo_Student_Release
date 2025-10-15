# =================================================#
# 				Alle Meine Entchen				   #			
# (c) Mitja Kocjančič, 13.12.2020 16:20 PM		   #
# =================================================#
#                                                  #
#  			Ču se je oženil: 	                   #
# {Note | Velocity | Stevilo ponavljanj} //Nota    #
# {60   | 1        | 1                 } //C       #
# {62   | 1        | 1                 } //D       #
# {64   | 1        | 1                 } //E       #
# {65   | 1        | 1                 } //F       #
# {67   | 2        | 2                 } //G,G     #
# {69   | 1        | 4                 } //A,A,A,A #
# {67   | 4        | 1                 } //G       #
# {69   | 1        | 4                 } //A,A,A,A #
# {67   | 4        | 1                 } //G       #
# {65   | 1        | 4                 } //F,F,F,F #
# {64   | 2        | 2                 } //E,E     #
# {62   | 1        | 4                 } //D,D,D,D #
# {60   | 4        | 1                 } //C       #
#                                                  #      
#==================================================#

main:	li r0, 27			# r0 is the main loop counter (Pesmica je dolga 27 taktov)

		li r1, 1			# Used to RESET Speaker 
		
	
loop:	li r2, 60			# Note (C)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions
		
		li r2, 62			# Note (D)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions
		

		li r2, 64			# Note (E)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions
		
		li r2, 65			# Note (F)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions
		
		li r2, 67			# Note (G)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions (Reset je bedno vezan, tako da je number of repetition - 1)
		
rep:	li r3, 0			# Write numebr we are decremating to screen
		sw  r3, 49154		# Note velocity
		li r3, 127
		sw  r3, 49154		# Note velocity
		subi	r4, r4, 1	# Ce tega komentarja ni, se program nece prevest WTF!!!
jnez	r4, rep
	
		li r2, 69			# Note (A)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 3			# Number of repetitions (Reset je bedno vezan, tako da je number of repetition - 1)

rep1:	li r3, 0			# Write numebr we are decremating to screen
		sw  r3, 49154		# Note velocity
		li r3, 127
		sw  r3, 49154		# Note velocity
		subi	r4, r4, 1	# Ce tega komentarja ni, se program nece prevest WTF!!!
jnez	r4, rep1

		li r2, 67			# Note (G)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions (Reset je bedno vezan, tako da je number of repetition - 1)

lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica

		li r2, 69			# Note (A)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 3			# Number of repetitions (Reset je bedno vezan, tako da je number of repetition - 1)

rep2:	li r3, 0			# Write numebr we are decremating to screen
		sw  r3, 49154		# Note velocity
		li r3, 127
		sw  r3, 49154		# Note velocity
		subi	r4, r4, 1	# Ce tega komentarja ni, se program nece prevest WTF!!!
jnez	r4, rep2

		li r2, 67			# Note (G)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions (Reset je bedno vezan, tako da je number of repetition - 1)

lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica


		li r2, 65			# Note (F)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 3			# Number of repetitions (Reset je bedno vezan, tako da je number of repetition - 1)

rep3:	li r3, 0			# Write numebr we are decremating to screen
		sw  r3, 49154		# Note velocity
		li r3, 127
		sw  r3, 49154		# Note velocity
		subi	r4, r4, 1	# Ce tega komentarja ni, se program nece prevest WTF!!!
jnez	r4, rep3

		li r2, 64			# Note (E)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions
		
rep4:	li r3, 0			# Write numebr we are decremating to screen
		sw  r3, 49154		# Note velocity
		li r3, 127
		sw  r3, 49154		# Note velocity
		subi	r4, r4, 1	# Ce tega komentarja ni, se program nece prevest WTF!!!
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
jnez	r4, rep4

		li r2, 62			# Note (D)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 3			# Number of repetitions
		
rep5:	li r3, 0			# Write numebr we are decremating to screen
		sw  r3, 49154		# Note velocity
		li r3, 127
		sw  r3, 49154		# Note velocity
		subi	r4, r4, 1	# Ce tega komentarja ni, se program nece prevest WTF!!!
jnez	r4, rep5

		li r2, 60			# Note (C)
		li r3, 127			# Velocity
		sw  r2, 49153 		# Send to Notes buffer
		sw  r3, 49154		# Note velocity
		li r4, 1			# Number of repetitions

#To je pa masilo (3*10*2*2*2 urine periode pavze), zato da ni tako nadlezna pesmica (ko se zadnji odmev konča, šele začne od začetka)
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		lwi r7, r7, 0 #To je pa masilo (3 urine periode pavze), zato da ni tako nadlezna pesmica
		
		#Nastavi napravo na začetno stanje
		li r3, 0			# Velocity
		sw  r3, 49154		# Note velocity
		li r2, 0
		sw  r2, 49153 		# Send to Notes buffer
		

jnez	r0, loop			# loop if r0 != 0

#Speaker parameters
#49152 = Speaker RESET
#49153 = Note
#49154 = Note Velocity