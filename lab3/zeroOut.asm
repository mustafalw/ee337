ORG 00H
LJMP MAIN

readNibble:
;=========================================
; Routine to read in Port lines P1.3 - P1.0 as a sngle nibble
; Returns the nibble in lower 4 bits of the register A
;
; Ensure that the internal port latches are set high already 
; prior to calling this routine
;=========================================
	MOV A,P1			; read port lines P1.3 - P1.0 where slide switches are connected
	ANL A,#0FH			; retain lower nibble and mask off upper one
	RET					; Return to caller with nibble in A

zeroOut:
	USING 0
	PUSH AR0 ;-- pushing the registers which are going to be
	PUSH AR2 ;-- used by this subroutine
	MOV R2, 50H ;-- Load 50H in R2, which stores the number of bytes to be cleared
	MOV R0, 51H ;-- Load 51H in R0, which stores the address of the first byte
	CLR A ; A is zeroed out and it will be moved to the locations to be cleared in the loop
	LOOP:
		MOV @R0, A ;-- Moving A i.e. #00H to the memory locations to be cleared
		INC R0     ;-- incrementing R0 to point to the next memory location
		DJNZ R2, LOOP
	POP AR2 ;-- popping the register in the exact reverse order before
	POP AR0 ;-- exiting from the subroutine
	RET
	
MAIN:
	; Port initialisation
	MOV P1,#0Fh			; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
	; read nibble from port
	LCALL readNibble		; read nibble using subroutine
	MOV 50H, A				; save nibble read in location 50H
	SWAP A
	ORL A, #0FH
	MOV P1, A
	MOV SP, #0CFH ;-- initialising stack pointer to 0CFH
	MOV 51H, #60H ;-- starting from 60H
	MOV 60H, #0H ;-- initialising the memory locations to
	MOV 61H, #1H ;-- be cleared by the subriutine with
	MOV 62H, #2H ;-- dummy values for verification
	MOV 63H, #3H
	MOV 64H, #4H
	LCALL zeroOut

STOP: JMP STOP

END
