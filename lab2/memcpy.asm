;A program to copy data stored in locations
;starting from A to locations starting from
;B. The locations may overlap therefore,
;forward copy has been used if A>=B and
;backward copy if A<B, to prevent loss of
;data due to overwriting

ORG 00H
LJMP MAIN

memcpy:
	USING 0
	PUSH AR0 ;-- pushing the registers which are going to be
	PUSH AR1 ;-- used by this subroutine
	PUSH AR2
	; comparing A and B
	MOV R2, 50H ; loading the number of memory locations to be copied
	MOV A, 51H ; loading A in accumulator
	MOV R1, 52H ; loading B in R1
	CLR C
	SUBB A, R1 ; subtracting to compare A and B
	JC BKWDCPY ; backward copy if carry was set
	MOV R0, 51H ; otherwise forward copy
	FRWDCPY:
			MOV A, @R0 ;-- Move the byte to A
			MOV @R1, A ;-- then move it from A to the designated location
			INC R0 ;-- increment both the pointers
			INC R1
			DJNZ R2, FRWDCPY
	JMP DONE
	BKWDCPY:
		MOV A, 51H ;-- arithmetic to get to the last memory location
		ADD A, R2 ;-- to start backward copying
		MOV R0, A
		MOV A, 52H
		ADD A, R2
		MOV R1, A
		LOOP:
			DEC R0
			DEC R1
			MOV A, @R0
			MOV @R1, A
			DJNZ R2, LOOP
	DONE:
	POP AR2 ;-- popping the register in the exact reverse order before
	POP AR1 ;-- exiting from the subroutine
	POP AR0
	RET

MAIN:
	MOV 50H, #7 ;-- 7 bytes to be copied
	MOV 51H, #60H ;-- starting from 60H
	MOV 52H, #70H ;-- to 7 bytes starting from 70H
	LCALL memcpy

STOP: SJMP STOP

END