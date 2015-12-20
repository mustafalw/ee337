	ORG 00H
	
SUMN:
	
	USING 0 ; Using the 0th register bank
	MOV R0, 50H ; Loading the value of N from 50H to R0
	MOV R1, #51H ; R1 stores the address of the register where partial sum has to be written
	MOV A, #0H ; Initialising A
	MOV R2, #0H ; R2 stores the number to be added to the A i.e. consecutive natural numbers
	LOOP:
		INC R2
		ADD A, R2
		MOV @R1, A ; Moving partial sum
		INC R1
		DJNZ R0, LOOP ; Loop ends after N iterations
		
STOP: JMP STOP

END