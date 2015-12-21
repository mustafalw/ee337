;======================MAIN====================
ORG 0H
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

readNibble :
	push ar0 ;-- pushing the registers being used in this program
	; Routine to read a nibble and confirm from user
	; First configure switches as input and LED’s as Output.
	; To configure port as Output clear it
	; To configure port as input, set it.
	; Logic to read a 4 bit number (nibble) and get confirmation from user
	loop:
		;turn on all 4 leds (routine is ready to accept input)
		mov p1, #0ffh
		;wait for 5 sec during which user can give input through switches
		mov 4fh, #10 ;-- moving 10 to 4FH to generate a delay of 5 seconds from LCALL
		lcall delay
		;turn off all LEDS
		mov p1, #0fh
		;read the input from switches (nibble)
		mov r0, p1 ;-- P1 is saved in R0
		;wait for one sec
		mov 4fh, #2
		lcall delay
		;show the read value on LEDs
		mov a, r0 ;-- moving the read value from R0 to ACC
		swap a
		orl a, #0fh
		mov p1, a
		;wait for 5 sec ( during this time delay User can put all switches to OFF
		;2position to signal that the read value is correct and routine can proceed to
		;next step)
		mov 4fh, #10
		lcall delay
		;clear leds
		mov p1, #0fh
		;read the input from switches
		mov a, p1
		;if read value <> 0Fh go to loop
		cjne a, #0fh, loop
	; return to caller with previously read nibble in location 4EH (lower 4 bits).
	mov 4eh, r0 ;-- moving the previously read nibble to lower bits of 4EH
	pop ar0 ;-- popping the registers before returning
	ret

packNibble:
	push ar0 ;-- push the registers being used in this program
	lcall readnibble ;-- call readNibble to read the 4 bits and store it in lower 4 bits of 4EH
	mov a, 4eh ;-- move the read value from 4EH to ACC
	swap a ;-- swapping ACC as the 4 bits read are the higher 4 bits of the byte to be read
	anl a, #0f0h ;-- ensuring that the value in the ACC has lower 4 bits as zeroes
	mov r0, a ;-- moving ACC to R0 as the next call to readNibble might alter ACC
	lcall readnibble ;-- call readNibble to read the 4 bits and store it in lower 4 bits of 4EH
	mov a, 4eh ;-- move the read value from 4EH to ACC
	anl a, #0fh ;-- ensuring that the value in the ACC has higher 4 bits as zeroes
	orl 0, a ;- R0 = R0|ACC, since R0 had upper 4 bits only and ACC had lower 4 bits
	mov 4fh, r0 ;-- finally moving the whole byte read from R0 to 4FH
	pop ar0 ;-- popping the registers before returning
	ret

readValues:
	push ar0 ;-- pushing the registers being used in this program
	push ar1
	mov r0, 50h ;-- R0 = number of bytes to be read
	mov r1, 51h ;-- R1 = starting address from where the read bytes need to be stored
	loop_readValues:
		lcall packNibble ;-- packnibble will read and store 1 byte in 4FH
		mov @r1, 4fh ;-- moving the read byte from 4FH to the required address
		inc r1 ;-- R1 = R1 + 1
		djnz r0, loop_readValues
	pop ar1 ;-- popping the registers before returning
	pop ar0
	ret

shuffleBits:
	using 0
	push ar0 ;-- pushing the registers being used in this program
	push ar1
	push ar2
	mov r2, 50h ;-- R2 = the value of K i.e. the number of elements in the array
	mov r0, 51h ;-- R0 = pointer to the first array starting
	mov r1, 52h ;-- R1 = pointer to the second array starting
	dec r2 ;-- the loop runs only till K-1 since the Kth case needs to handled separately
	loop_shuffle:
		mov a, @r0 ;-- ACC = @R0
		inc r0 ;-- R0 = R0 + 1
		xrl a, @r0 ;-- ACC = ACC^@R0
		mov @r1, a ;-- @R1 = ACC
		inc r1 ;-- R1 = R1 + 1
		djnz r2, loop_shuffle
	mov a, @r0 ;-- ACC = A[K-1]
	mov r0, 51h ;-- R0 = the starting address of the array A
	xrl a, @r0 ;-- ACC = ACC^A[0]
	mov @r1, a ;-- moving ACC to the specified location
	pop ar2 ;-- popping the registers before returning
	pop ar1
	pop ar0
	ret

displayValues:
	push ar0 ;-- pushing the registers being used in this program
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
		jc next ;-- if carry is set then, input from port > K, jump to displayValues
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
	pop ar3 ;-- popping the registers before returning
	pop ar2
	pop ar1
	pop ar0
	ret

MAIN:
	MOV SP,#0CFH;-----------------------Initialize STACK POINTER
	MOV 50H,#4;------------------------Set value of K
	MOV 51H,#60H;------------------------Array A start location
	MOV 4FH,#00H;------------------------Clear location 4FH
	LCALL readValues
	
	MOV 50H,#4;------------------------Value of K
	MOV 51H,#60H;------------------------Array A start location
	MOV 52H,#70H;------------------------Array B start location
	LCALL shuffleBits
	
	MOV 50H,#4;------------------------Value of K
	MOV 51H,#70H;------------------------Array B start Location
	LCALL displayValues;----------------Display the last four bits of elements on LEDs
	
here:SJMP here;---------------------WHILE loop(Infinite Loop)
END
; ------------------------------------END MAIN------------------------------------