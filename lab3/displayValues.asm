org 00h
ljmp main

delay:
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

displayValues:
	push ar0
	push ar1
	push ar2
	push ar3
	next:
		mov a, 50h ;-- ACC = the value of k
		mov r1, 51h ;-- r1 = address of the first location
		mov p1, #0fh ;-- set the internal latches of the lower nibble high to read P1
		mov r0, p1 ;-- reading P1 and storing in R0
		mov r2, p1 ;-- r2 = the value read from port
		clr c ;-- clear carry as the next instruction is subtract
		subb a, r0 ;-- subtract R0 from ACC
		jc return ;-- if carry is set then, input from port > K, jump to displayValues
		mov a, r2 ;-- else move the address of the first byte to ACC
		add a, r1 ;-- add the value read from the port
		mov r1, a ;-- move the result of addition to R1
		dec r1 ;-- decrement R1 to get to the actual location of the required byte
		mov a, @r1 ;-- move the byte to be displayed to ACC
		mov p1, a ;-- move the value from ACC to P1
		swap a ;-- swap ACC to get the lower nibble from A4 to A7
		mov r3, a ;-- move ACC to R3 since ACC might get modified in the delay subroutine
		mov 4fh, #4 ;-- moving #4 in 4fh as delay of 2 seconds is needed
		lcall delay ;-- delay of 2 seconds
		mov p1, r3 ;-- display the lower nibble
		lcall delay
		jmp next ;-- jump back to the start of the subroutine to display continuously
return:	pop ar3
		pop ar2
		pop ar1
		pop ar0
	ret

main:
	mov 50h, #5 ;-- 5 bytes are stored
	mov 51h, #60H ;-- starting from the address 60H
	MOV 60H, #80H
	MOV 61H, #71H
	MOV 62H, #62H
	MOV 63H, #53H
	MOV 64H, #4FH
	lcall displayValues

stop: jmp stop

end