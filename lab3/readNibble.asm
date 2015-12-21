org 00h
ljmp main

delay:
	USING 0
	PUSH 0E0H
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
	POP 0E0H
	RET

readNibble :
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
	ret

main:
	lcall readNibble
	
stop: jmp stop

end