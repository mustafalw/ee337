
; setup code at reset vector (0000H) to point to our main program
ORG 00H
	; 
LJMP MAIN

DELAY:
	USING 0
	PUSH AR0 ;-- pushing the registers which are going to be
	PUSH AR1 ;-- used by this subroutine
	PUSH AR2
	MOV A, 4FH ;-- Move the value of D from 4FH to A
	MOV B, #10 ;-- Load 10 in B
	MUL AB     ;-- Multiply 10 with D to get the number of iterations for the 50ms loop
	MOV R0, A  ;-- Move the result to R0 which is used as the iterator in the loop
	BACK1:
		;-- the following is a nested loop which generates a
		;-- delay of 50ms. This delay has been iterated 10D
		;-- times to get a total delay of 500Dms = D/2 seconds
		MOV R2,#200
		BACK2:
			MOV R1,#0FFH
			BACK3:
				DJNZ R1, BACK3
			DJNZ R2, BACK2
		DJNZ R0, BACK1
	POP AR2 ;-- popping the register in the exact reverse order before
	POP AR1 ;-- exiting from the subroutine
	POP AR0
	RET

MAIN:
	MOV SP, #0CFH ;-- initialising stack pointer to 0CFH
	MOV 4FH, #2	  ;-- setting D = 4 seconds
	CLR P1.4      ;-- clearing the output pin 4 of P1
	LOOP:
		LCALL DELAY ;-- call the delay subroutine to generate the required delay
		CPL P1.4    ;-- complement the pin after the delay
		SJMP LOOP   ;-- keep repeting indefinitely

STOP: JMP STOP

END