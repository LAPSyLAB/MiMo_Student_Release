# General test

## 1: @testing unconditionals with no set flags and no jumps
		.data

		.space 4
		.word 12

		.text

		mov r1, #5  	@in register after cycle 5
		mov r2, #4  	@cycle 6
		nop 			@there has to be 3 nop's if we want to use the same operands right away so there are no pipeline hazards
		nop
		nop
		add r4, r1, r2 	@cycle 10
		ldr r3, #1 		@cycle 11
		str r1, #2 		@cycle 12
		sub r5, r1, r2 	@cycle 13
		mul r6, r1, r2	@cycle 14
		rsb r3, r3, r4 	@cycle 15
				@or there has to be 3 different instructions that don't use the changed variables like here
				@ we calculate r4 and r3, then we have 3 different instructions and then we reverse subtract r3 and r4

## 2: @testing setting flags and conditionals
		.text

		mov r1, #4	 		@cycle 5
		mov r2, #5	 		@cycle 6
		mov r3, #3	 		@cycle 7
		mov r4, #5	 		@cycle 8
		nop
		cmp r1, r2	 		@cycle 10
		nop		 			@cycle 11, has to be added because the result of the flags is known one stage late
		addeq r5, r1, r2 	@cycle 12
		addcs r0, r1,r2  	@cycle 13, does not execute because condition is not met but we only lose one cycle
		subs r6, r3, r4  	@cycle 14
		nop		 			@cycle 15
		remne r7, r3, r4 	@cycle 16
## 3: @testing jumps
	.text

	mov r1, #1		@cycle 5
	mov r2, #2		@cycle 6
	nop
	nop
	nop
	loop: mul r1, r1, r2	@cycle 10,16,22,28 - we lose 6 cycles for every jump
	j loop			@cycle 11
## 4: @testing jumps with instructions after jump command
		.text

		mov r1, #1	@cycle 5
		mov r2, #2	@cycle 6
		mov r3, #3	@cycle 7
		mov r4, #1	@cycle 8
		nop			@cycle 9
		loop:
		mul r1, r1, r2	@cycle 10, 16, 22, 28...
		j loop			@cycle 11
		add r3, r3, r4	@these do not execute
		sub r5, r1, r2	@these do not execute
## 5: @testing conditional jumps
		.text

		mov r1, #5		@cycle 5
		mov r2, #7		@cycle 6
		loop: add r0, r0, #1	@cycle 7
		nop				@cycle 8
		nop				@cycle 9
		adds r3, r1, r2		@cycle 10
		nop				@cycle 11
		jne loop		@cycle 12, does not execute
		sub r4, r1, r2	@cycle 13
## 6: @testing jump to register
		.text

		mov r1, #5	@cycle 5
		mov r3, #10	@cycle 6
		nop			@cycle 7
		nop			@cycle 8
		nop			@cycle 9
		add r2, r2, #1	@cycle 10
		nop			@cycle 11	
		nop			@cycle 12
		nop			@cycle 13
		cmp r2, r3	@cycle 14
		nop			@cycle 15
		jmi r1		@cycle 16

## 7: @testing jump to subroutine and return
        .text

        mov r1, #3			@cycle 5
        mov r2, #2			@cycle 6
        @nop				@cycle 7
        @nop				@cycle 8
        bl subroutine		@cycle 9
        add r0, r0, #1		@cycle 16
        add r7, r7, #1		@cycle 17
        add r6, r6, #1		@cycle 18

        subroutine: 
        add r0, r0, r1		@cycle 11
        add r7, r7, #5		@cycle 12
        add r6, r6, #10		@cycle 13
        rts					@cycle 14
## 8: @testing ldr with [rs], [rs, rt] and [rs, immed]

		.data

		.space 4
		.word 2
		.word 4
		.word 7

		.text

		mov r1, #1			@cycle 5
		mov r2, #1			@cycle 6
		nop					@cycle 7
		nop					@cycle 8
		ldr r3, [r1]		@cycle 9
		ldr r4, [r1, r2]	@cycle 10
		ldr r5, [r1, #2]	@cycle 11
		
# Stall and forwarding tests:

## 1: @testing plain (no-stall) with nops inserted
		.text

		mov r1, #3		@cycle 5
		mov r2, #3		@cycle 6
		nop				@cycle 7		
		nop				@cycle 8
		nop				@cycle 9
		cmp r1, r2		@cycle 10
		nop				@cycle 11
		streq r1, #3	@cycle 12

## 2: @testing stall version without nops inserted
		.text

		mov r1, #3		@cycle 5
		mov r2, #3		@cycle 6
		cmp r1, r2		@cycle 10
		streq r1, #3	@cycle 12

## 3: @testing operand forwarding
		.data

		.space 4
		.word 16

		.text

		mov r1, #3			@cycle 5
		mov r2, #4			@cycle 6
		mov r6, #2			@cycle 7	
		add r3, r1, r2		@cycle 8
		mov r4, #12			@cycle 9
		subs r3, r1, r2		@cycle 10
		movmi r5, #20		@cycle 11
		add r1, r1, #5		@cycle 12
		add r2, r1, r2		@cycle 13
		add r3, r1, r2		@cycle 14 - RAW, no cycle lost
		mov r0, #1			@cycle 15
		ldr r7, [r0]		@cycle 16 
		add r2, r0, r7		@cycle 18 - RAW, 1 cycle lost (MA)
## 4: @testing how delays occur for jumping instructions in op forwarding version
		.text

		@loop:
		mov r0, #1
		add r1, r1, #3	@cycle 5, 10, 15, 20, 25, 30 ...
		add r2, r2, #3	@cycle 6, 11, 16
		add r3, r1, r2	@cycle 7, 12, 17
		j r0			@cycle 8, 13, 18
		mov r4, #4
## 5: @testing comparison stall vs forwarding timings
		.data

		.word 1

		.text

		loop:			@ stall										| forwarding
		mov r3, #3		@ 5, 22										| 5, 17	
		ldr r1, [r2]	@ 6, 23										| 6, 18
		add r1, r1, #1	@ 10, 27									| 8, 20 (here one mandatory stall is used to get the value from the MA stage)
		add r7, r7, #1  @ 11, 28									| 9, 21
		str r2, r1		@ 14 (written to operand memory on cycle 13, but left pipeline on 14), 31	| 10, 22
		subs r4, r3, r1	@ 15, 32									| 11, 23
		add r5, r5, #1  @ 17, 34									| 12, 24
		add r7, r7, #1  @ 18, 35									| 13, 25
		add r6, r1, r4  @ 19, 36									| 14, 26
		jne loop		@ 20, 37									| 15, 27
## 6: @example from the HiP lecture for simple loop comparison
		@ and is meant to showcase the difference between stall and forwarding

		.data

		.word 1

		.text

		mov r3,#3		@ 5

		loop:			@ stall									| forwarding
		ldr r1, [r2]	@ 6, 19									| 6, 13
		add r1, r1, #1	@ 10, 23								| 8, 15 (here one mandatory stall is used to get the value from the MA stage)
		str r1, [r2]	@ 14, 27								| 9, 16	 
		subs r4, r3, r1	@ 15, 28								| 10, 17
		jne loop		@ 17, 30								| 11, 18
## 7: @testing comparison stall vs forwarding timings for various ldr
		.data

		.word 1, 2, 3

		.text

						@ stall		| forwarding
		mov r1, #3 		@5 			|5
		add r5, r1, #1 	@9 			|6
		mov r0, #1 		@10 		|7
		ldr r1, [r0] 	@14			|8
		add r6, r1, #1 	@18			|10
		mov r2, #1 		@19			|11
		ldr r1, [r0, r2] @23		|12
		add r7, r1, #1 	@27			|14

## 8: @testing comparison stall vs forwarding timings for various str
		.text

						@ stall		| forwarding
		mov r1, #10 	@5			|5
		mov r2, #5 		@6			|6
		mov r0, #1 		@7			|7
		str r2, #0 		@11			|8
		str r1, [r0] 	@12			|9
		mov r3, #2 		@13			|10
		str r2, [r0, r3] @17		|11

# Prediction tests:

## 1: @revised example 1-bit vs 2-bit predictor on changing condition
		/*
		b=1
		while (true){
			if(a % 2 == 0){jump1}	TNTNTNTNTNT
			a++	
		}
		a => r0, r1 => used for counting jump1 calls

		*/

		.text

		loop: 
		rem r0, r0, #2
		cmp r0, #0
		jeq jump1
		add r0, r0, #1
		j loop

		jump1:
		add r0, r0, #1
		add r1, r1, #1
		j loop


Results:

		using 1-bit predictor: no predictions are correct
		using 2-bit predictor: 50% of predictions are correct because it starts in state 00 (Strong Not Taken)

## 2: @revised example 1-bit vs 2-bit predictor on nested loop
		.text

		mov r0, #8

		loop: 
		mov r1, #8

		repeat:
		subs r1, r1, #1
		bne repeat
		add r0, r0, #1
		b  loop

*The conditional loop (bne repeat) runs 8 times.
The 1-bit predictor fails on first loop enter then fails again on loop exit.
Every next loop it fails twice on loop enter and exit, so out of every 8 predictions, 2 are failures, out of 24 predictions, 6 are failures
The 2-bit predictor fails twice on first loop enter because it's starting value is 00(Strong Not Taken).
It fails once on loop exit because it's value is 11(Strong Taken). 
On loop reenter it succeeds because it's value is 10(Weak Taken)
Out of every 8 predictions, 1 is a failure. Out of 24 predictions 5 are failures (1*3 + 2 at the beginning).*

Results:

		using no prediction(branch not taken): 21/24 predictions are incorrect
		using 1-bit predictor: 6/24 predictions are incorrect
		using 2-bit predictor: 5/24 predictions are incorrect
		using correlating LHT: 13/24 incorrect
		using correlating 2 by 2: 10/24 incorrect
		using tournament: 13/24 incorrect

## 3: corr_lht: @testing correlating predictor
@sometimes 2 branches can take up the same spot in our local prediction table
@because we use a 3 bit addressed LPT, this happens if 2 instructions seperated by 8 addresses are both branches

		/*
		while (true){
			if(a % 2 == 0){jump1}	TNTNTNTNTNT
			a++		
			if(b == 1){jump2}	NNNNNNNNNNN
		}
		a => r0, b => r1, r5=>stalling command, r3,r4 => counting loops for a and b
		*/

		.text

		loop: 
		rem r0, r0, #2
		cmp r0, #0
		jeq jump1	@2nd instruction

		afterjump1:
		add r0, r0, #1
		add r5, r5, #1
		add r5, r5, #1
		add r5, r5, #1
		add r5, r5, #1
		add r5, r5, #1
		cmp r1, #1
		jeq jump2	@10th instruction, last 3 bits are 010 so it'll have the same LPT spot as the 2nd instruction
		add r4, r4, #1
		j loop

		jump1:
		add r3, r3, #1
		j afterjump1

		jump2:
		mov r6, #15

Branch outcomes				Branch predictions when using only 2 bit table: (lpt: 00 -> 01 -> 00 -> 00 -> 00...
jump1		TNTNTNTNTNTNTNTN	jump1	NNNNNN
jump2 		NNNNNNNNNNNNNNNN	jump2	NNNNNN

Because they take up the same spot in our LPT, we misspredict jump1 every second loop
Table states when using correlating predictor:
LHT: 000 -> 100 -> 010 -> 001 ->	000 -> 		100
LPT: 00 -> 01(00) -> 01(00)(00) -> 01(00)(00)(00) -> 10(00)(00)(00)

Branch predictions when using correlating predictor:
jump1: NNNNTNTNTNTN	
jump2: NNNNNNNNNNNN

 The predictions are on average more correct using a correlating predictor when 2 jumps take up the same LPT address.
 After the 4th iteration in our example above, we predict correct jumps everytime for each of our jump instructions.

## 4: corr_2by2: @testing 2by2 correlating predictor
@The LHT correlating predictor does not work well in all situations
@Sometimes, unrelated jumps(that do not share the same address space in the LHT) may affect the correlating predictor and make predictions worse.
@ Another version of a correlating predictor is one that does not relly on the address space.
@ It is composed of 4 2-bit predictors and a 'Master' register that dinamically chooses which of the 2-bit predictors to use based on previous predictions
@ we'll take the same code as with our LHT correlating predictor, but expand it with an extra unrelated jump (with diffrent last 3 address bits)

		/*
		while (true){
			if(a % 2 == 0){jump1}	TNTNTNTNTNT
			a++		
			if(b == 1){jump2}	NNNNNNNNNNN
			
			if(c % 2 == 0){jump3}	TNTNTNTNTNT
			c++
		}
		a => r0, b => r1, c=> r2, r5=>stalling command, r3,r4,r6 => counting loops for a, b and c
		*/

		.text

		loop: 
		rem r0, r0, #2
		cmp r0, #0
		jeq jump1	@2nd instruction

		afterjump1:
		add r0, r0, #1
		add r5, r5, #1
		add r5, r5, #1
		add r5, r5, #1
		add r5, r5, #1
		add r5, r5, #1
		cmp r1, #1
		jeq jump2	@10th instruction, same last 3 bits as jump1
		add r4, r4, #1
		rem r2, r2, #2
		cmp r2, #0
		jeq jump3 	@another jump, independant to the last 2
		afterjump3:
		add r2, r2, #1
		j loop

		jump1:
		add r3, r3, #1
		j afterjump1

		jump2:
		mov r7, #15

		jump3:
		add r6, r6, #1
		j afterjump3

Results:

			2-bit predictor: 34/100 predictions incorrect
			LHT predictor: 18/100 incorrect
			Correlating 2by2: 4/100 incorrect
			Tournament predictor: 19/100 incorrect

## 5: tournament: @testing tournament predictor
@The correlating predictor is not always better than a standard 2-bit predictor
@Sometimes, unrelated jumps may affect the correlating predictor and make predictions worse.
@To account for that, we can also use a tournament predictor,
@ that dinamically chooses whether to to predict using local history(as a correlating predictor) or global history(2-bit predictor)

@In the example below, The correct prediction pattern is TTTTNTTTTNTTNTTT... at different intervals, for each jump every 8 predictions it fails
@This works well for a standard 2-bit predictor, but not as well for our 2 versions of the correlating predictor

		/*
		while(true){
				a++
				if (a % 8 !== 0) {
				  jump1
				}
				b++
				if (b % 8 !== 2) {
				  jump2    	
			}
			c++
				if (c % 8 !== 4) {
				  jump3	
			}
			d++
				if (d % 8 !== 6) {
				  jump4
			}
		}
		*/

		.text

		loop:
		add r0, r0, #1
		rems r2, r0, #8
		jne jump1
		afterjump1:
		rem r2, r0, #8
		cmp r2, #2
		jne jump2
		afterjump2:
		rem r2, r0, #8
		cmp r2, #4
		jne jump3
		afterjump3:
		rem r2, r0, #8
		cmp r2, #6
		jne jump4
		j loop

		jump1:
		add r5, r5, #1
		j afterjump1

		jump2:
		add r6, r6, #1
		j afterjump2

		jump3:
		add r7, r7, #1
		j afterjump3

		jump4:
		add r4, r4, #1
		j loop


Results:

		2-bit predictor: 22/112 predictions incorrect
		LHT predictor: 27/112 incorrect
		Correlating 2by2: 39/112 incorrect
		Tournament predictor: 23/112 incorrect

		When using the tournament predictor on test3, only the first 2 predictions are incorrect, just like with the LHT predictor.
		This is the advantage of the Tournament predictor, it is not always the best but it is the most flexible in different kinds of programs.
		
## 6: bubble_sort: @testing Bubble sort algorithm

		/*
		void bubbleSort(vector<int>& arr) {
			int n = arr.size();
		  
			for (int i = 0; i < n - 1; i++) {
				for (int j = 0; j < n - i - 1; j++) {
					if (arr[j] > arr[j + 1]) {
						swap(arr[j], arr[j + 1]);
					}
				}
			}
		*/


		@ Bubble sort algorithm


		.data
		.word 10 @array size
		.word 42, 17, 88, 23, 54, 75, 12, 67, 31, 99 @array elements

		.text

		ldr r0, #0		@ r0 -> size and outer loop counter
		sub r0, r0, #1 		@ size = size - 1

		sort_outer:
		cmp r0, #0		@ Check if outer loop is done
		beq sort_done		@ Exit if size == 0			
		mov r1, r0		@ r1 is inner loop counter
		mov r2, #1		@ r2 points to array

		sort_inner:
		cmp r1, #0		@ Check if inner loop is done
		beq sort_outer_dec	@ Exit inner loop if r1 == 0
		ldr r3, [r2]		@ Load array[j]
		ldr r4, [r2, #1]	@ Load array[j+1]
		cmp r3, r4		@ Compare array[j] and array[j+1]
		ble sort_inner_next	@ Skip swap if array[j] <= array[j+1]
		str r4, [r2]		@ Swap array[j] and array[j+1]
		str r3, [r2, #1]

		sort_inner_next:
		add r2, r2, #1		@ Move on to next pair in array
		sub r1, r1, #1		@ Decrement inner loop counter
		b sort_inner


		sort_outer_dec:
		sub r0, r0, #1		@ Decrement outer loop counter
		b sort_outer

		sort_done:
		mov r7, #1


Results:

Number of incorrect prediction to complete whole sort (total predictions:109)

		no prediction: 37
		1-bit: 52
		2-bit: 32
		correlating LHT: 37
		correlating 2 by 2: 24
		tournament: 30

Number of cycles to complete sorting:
		no prediction: 605
		1-bit: 620
		2-bit: 600
		correlating LHT: 605
		correlating 2 by 2: 592
		tournament: 598
		

## 7: HIP_loop: @example showcases the efficiency provided by each prediction method using MiMo v2.3
		.data

		.word 1

		.text

		mov r3,#15

		loop:
		ldr r1, [r2]	
		add r1, r1, #1	
		str r1, [r2]	
		subs r4, r3, r1	
		jne loop

		mov r7, #7

Results:


		using no prediction(branch not taken): 
									13/14 prediction are incorrect, end cycle 116
		using 1-bit predictor: 		2/14 predictions are incorrect, end cycle 105
		using 2-bit predictor: 		3/14 prediction are incorrect, 	end cycle 106
		using correlating LHT: 		6/14 incorrect, 				end cycle 109
		using correlating 2 by 2: 	5/14 incorrect, 				end cycle 108
		using tournament: 			6/14 incorrect, 				end cycle 109
