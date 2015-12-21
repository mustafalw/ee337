;This program reads a value N from 50H
;and P from 51H. It displays the last
;4 bits of the bytes stored from P to
;P+N-1 on an 4 LEDs connected to P1.7
;to P1.4

ORG 00H
LJMP MAIN

delay:
	USING 0
	PUSH AR5
	PUSH AR6
	PUSH AR7
	MOV A, 4FH
	MOV B, #10
	MUL AB
	MOV R7, A
	BACK1:
		MOV R6,#200
		BACK2:
			MOV R5,#0FFH
			BACK3:
				DJNZ R5, BACK3
			DJNZ R6, BACK2
		DJNZ R7, BACK1
	POP AR7
	POP AR6
	POP AR5
	RET

display:
	USING 0 ;-- pushing the registers which are going to be
	PUSH AR0 ;-- used by this subroutine
	PUSH AR1
	MOV R1, 50H ;-- Load 50H in R1, which stores the number of bytes to be read
	MOV R0, 51H ;-- Load 51H in R0, which stores the address of the first byte
	LOOP:
		MOV A, @R0 ;-- Moving the byte to A
		SWAP A ;-- Swapping as the last 4 bits are needed to be given to P1.4 to P1.7
		ANL A, #0F0H ;-- Clearing the last 4 bits by taking and with #0F0H
		MOV P1, A ;-- Move the accumulator to P1
		LCALL delay ;-- Delay of D/2 seconds
		INC R0 ;-- incrementing R0 to point to the next memory location
		DJNZ R1, LOOP
	POP AR1 ;-- popping the register in the exact reverse order before
	POP AR0 ;-- exiting from the subroutine
	RET
	
MAIN:
	MOV SP, #0CFH ;-- initialising stack pointer to 0CFH
	MOV 50H, #7 ;-- N = 7, bytes will be read
	MOV 51H, #60H ;-- starting from 60H
	MOV 4FH, #2
	MOV 60H, #9
	MOV 61H, #2
	MOV 62H, #3
	MOV 63H, #4
	MOV 64H, #5
	MOV 65H, #6
	MOV 66H, #7
	LCALL display
	
STOP: JMP STOP

END