	ORG 00H
		
ADD8:

	MOV A, 50H ; Load the first number from 50H to A
	MOV R1, 60H ; Move the second number from 60H to R1
	ADD A, R1 ; Adding R1 to A
	MOV 70H, A ; Moving the result from A to 70H
	
STOP: JMP STOP

END