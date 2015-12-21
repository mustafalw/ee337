
ORG 00H
LJMP MAIN

zeroOut:
	USING 0
	PUSH AR0
	PUSH AR2
	MOV R2, 50H
	MOV R0, 51H
	CLR A
	LOOP1:
		MOV @R0, A
		INC R0
		DJNZ R2, LOOP1
	POP AR2
	POP AR0
	RET

ORG 020H
sumOfSquares:
	USING 0
	PUSH AR0
	PUSH AR2
	PUSH AR3
	PUSH AR4
	MOV R2, 50H
	MOV R0, 51H
	MOV R3, #0H
	MOV R4, #0H
	LOOP2:
		INC R3
		;squaring R3
		MOV A, R3
		MOV B, R3
		MUL AB
		ADD A, R4
		MOV @R0, A
		MOV R4, A
		INC R0
		DJNZ R2, LOOP2
	POP AR4
	POP AR3
	POP AR2
	POP AR0
	RET
	
ORG 050H
memcpy:
	PUSH AR0
	PUSH AR1
	PUSH AR2
	MOV R2, 50H
	MOV A, 51H
	MOV R1, 52H
	CLR C
	SUBB A, R1
	JC BKWDCPY
	MOV R0, 51H
	FRWDCPY:
			MOV A, @R0
			MOV @R1, A
			INC R0
			INC R1
			DJNZ R2, FRWDCPY
	RET
	BKWDCPY:
		MOV A, 51H
		ADD A, R2
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
	POP AR2
	POP AR1
	POP AR0
	RET
	
ORG 080H
delay:
	USING 0
	PUSH AR0
	PUSH AR1
	PUSH AR2
	MOV A, 4FH
	MOV B, #10
	MUL AB
	MOV R0, A
	BACK1:
		MOV R2,#200
		BACK2:
			MOV R1,#0FFH
			BACK3:
				DJNZ R1, BACK3
			DJNZ R2, BACK2
		DJNZ R0, BACK1
	POP AR2
	POP AR1
	POP AR0
	RET

ORG 0A0H
display:
	USING 0
	PUSH AR0
	PUSH AR1
	MOV R1, 50H
	MOV R0, 51H
	LOOP3:
		MOV A, @R0
		SWAP A
		ANL A, #0F0H
		MOV P1, A
		LCALL delay
		INC R0
		DJNZ R1, LOOP3
	POP AR1
	POP AR0
	RET

ORG 0130H
MAIN:

	MOV SP,#0CFH;-----------------------Initialize STACK POINTER

	MOV 50H,#10;------------------------N memory locations of Array A
	MOV 51H,#60H;------------------------Array A start location
	LCALL zeroOut;----------------------Clear memory
	
	MOV 50H,#15;------------------------N memory locations of Array B
	MOV 51H,#70H;------------------------Array B start location
	LCALL zeroOut;----------------------Clear memory
	
	MOV 50H,#10;------------------------N memory locations of Array A
	MOV 51H,#60H;------------------------Array A start location
	LCALL sumOfSquares;-----------------Write at memory location
	
	MOV 50H,#10;------------------------N elements of Array A to be copied in Array B
	MOV 51H,#60H;------------------------Array A start location
	MOV 52H,#70H;------------------------Array B start location
	LCALL memcpy;-----------------------Copy block of memory to other location
	
	MOV 50H,#15H;------------------------N memory locations of Array B
	MOV 51H,#70H;------------------------Array B start location
	MOV 4FH,#2;------------------------User defined delay value
	LCALL display;----------------------Display the last four bits of elements on LEDs

here:SJMP here;---------------------WHILE loop(Infinite Loop)

END