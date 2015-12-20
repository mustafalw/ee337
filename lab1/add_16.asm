ORG 0000H
LJMP MAIN

;R0 and R1 should contain the address of two no.s
;location given by R0:- 	MSB of 1st no.
;location given by R0+1:-	LSB of 1st no.
;location given by R1:- 	MSB of 1st no.
;location given by R1+1:-	LSB of 1st no.
;location given by R0+2:- 	CARRY	
;location given by R0+3:-	MSB OF ANS	
;location given by R0+4:- 	LSB OF ANS

;---------------------------------------------------------;
;this function adds and stores result in appropriate location
ADDER_16BIT:
	;-- push the registers which will be affected by this subroutine
	;	but will be needed later
	USING 0
	PUSH AR0 ;-- push the registers which will be affected by this subroutine
	PUSH AR1 ;-- but will be needed later
	MOV R0, #60H ;-- 60H stores MSB of first number
	MOV R1, #70H ;-- 70H stores MSB of second number
	;-- the numbers are stored in big endian form
	INC R0 ; R0 = 61H, incrementing R0 so that it points to LSB of first number
	INC R1 ; R1 = 71H, incrementing R1 so that it points to LSB of second number
	CLR C		;-- Clearing carry before subtracting
	MOV A, @R0 ; Load LSB of first number in A
	ADD A, @R1 ; Add the LSB of the second number
	INC R0 ; R0 = 62H, incrementing R0 since the result needs to be stored in big
	INC R0 ; R0 = 63H, big endian format i.e. LSB in 64H, MSB in 63 H & carry bit in 62H
	INC R0 ; R0 = 64H
	MOV @R0, A ; Move the LSB of the result
	DEC R0 ; R0 = 63H
	DEC R0 ; R0 = 62H
	DEC R0 ; R0 = 61H
	DEC R0 ; R0 = 60H
	DEC R1 ; R1 = 70H
	MOV A, @R0 ; Load MSB of first number in A
	ADDC A, @R1 ; Add the MSB of second number with carry
	INC R0 ; R0 = 61H
	INC R0 ; R0 = 62H
	INC R0 ; R0 = 63H
	MOV @R0, A ; Move the MSB of the result 
	; Copying the carry bit to 62H
	CLR A
	ADDC A, #0H
	DEC R0 ; R0 = 62H
	MOV @R0, A ;-- Move carry bit to 62H
	RET
	
	RETURN:	
	;-- pop the registers
	POP AR1
	POP AR0
	RET
	
INIT:
	;-- store the numbers to be added/subtracted at appropriate location
	MOV 60H, #0FFH
	MOV 61H, #0FFH
	MOV 70H, #0FFH
	MOV 71H, #0FFH
	; RESULT = 1FFFE
	
	;MOV 60H, #80H
	;MOV 61H, #00H
	;MOV 70H, #80H
	;MOV 71H, #04H
	; RESULT = 10004
	
	;MOV 60H, #7FH
	;MOV 61H, #0FFH
	;MOV 70H, #7FH
	;MOV 71H, #0FFH
	; RESULT = 0FFFE
	
	;MOV 60H, #7FH
	;MOV 61H, #0FEH
	;MOV 70H, #0FFH
	;MOV 71H, #0FFH
	; RESULT = 07FFD
	
	;MOV 60H, #80H
	;MOV 61H, #00H
	;MOV 70H, #07FH
	;MOV 71H, #0FFH
	; RESULT = 1FFFF
	
	;MOV 60H, #0FFH
	;MOV 61H, #0FFH
	;MOV 70H, #00H
	;MOV 71H, #01H
	; RESULT = 00000
	
	;MOV 60H, #80H
	;MOV 61H, #00H
	;MOV 70H, #00H
	;MOV 71H, #01H
	; RESULT = 18001
	
	;MOV 60H, #7FH
	;MOV 61H, #0FFH
	;MOV 70H, #00H
	;MOV 71H, #01H
	; RESULT = 08000
	
	RET

ORG 0100H
MAIN:
	MOV SP,#0C0H	;move stack pointer to indirect RAM location
	ACALL INIT
	ACALL ADDER_16BIT

STOP: JMP STOP

END
