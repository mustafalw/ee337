;This program calculates the sum of squares
;of N natural numbers. N is stored in 50H.
;The partial sums are to be successively stored,
;starting from the location given in the 51H register

ORG 00H
LJMP MAIN

sumOfSquares:
	USING 0
	PUSH AR0 ;-- pushing the registers which are going to be
	PUSH AR2 ;-- used by this subroutine
	PUSH AR3
	PUSH AR4
	MOV R2, 50H ;Load the value of N in R2
	MOV R0, 51H ;Load the address of starting location in R0
	MOV R3, #0H ;R3 will store the successive natural numbers
	MOV R4, #0H ;R4 will store the partial sum
	LOOP:
		INC R3 ;-- R3 is incremented to generate the sequence of natural numbers
		MOV A, R3 ;-- squaring R3
		MOV B, R3
		MUL AB
		ADD A, R4 ;-- adding to the partial sum
		MOV @R0, A ;-- moving the partial sum to the memory
		MOV R4, A ;-- updating the partial sum
		INC R0 ;-- updating the pointer location
		DJNZ R2, LOOP
	POP AR4 ;-- popping the register in the exact reverse order before
	POP AR3 ;-- exiting from the subroutine
	POP AR2
	POP AR0
	RET
	
ORG 20H
MAIN:
	MOV SP, #0CFH ;-- initialising stack pointer to 0CFH
	MOV 50H, #6 ;-- N = 6
	MOV 51H, #60H ;-- start storing partial sums from 60H 
	LCALL sumOfSquares
	
STOP: JMP STOP

END