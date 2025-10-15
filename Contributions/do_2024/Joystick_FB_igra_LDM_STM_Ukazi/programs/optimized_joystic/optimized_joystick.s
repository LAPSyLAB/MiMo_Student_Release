main:   li r7, 0x0fff           # SP
        li r5, 0                # Register used to compare the previus and new vertical position
        li r4, 1                # Register used to perform LSL
loop:   lw r2, 0xC010           # Load the inverted horizontal value
        lsl r0, r4, r2         
        lw r1, 0xC011           # Load the inverted verical value
        beq r1, r5, skip        
        sw r0, 0x4fff           # Write to the reset register of the 16x16 matrix
        move r5, r1             
skip:   swi r0, r1, 0x4000      # Write to the 16x16 matrix
        br loop
        