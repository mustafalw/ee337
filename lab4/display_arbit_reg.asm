; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start

org 200h
start:
	; initialisation of the registers to be displayed
	mov r2, #0ffh-8H ; initialise 16 bytes
	mov r0, #8H ; starting from 90H in the indirectly addressable RAM
	init1:
		mov a, r0
		cpl a
		mov @r0, a
		inc r0
		djnz r2, init1

	;initial delay for lcd power up
	mov P2,#00h
	mov P1,#00h
	mov sp, #0cfh
		
	; read the nibble from P1, say X, and display 16 bytes from
	; X0H to XFH and keep repeating
	repeat:
		;initialise LCD
		acall delay
		acall delay
		acall lcd_init
		acall delay
		acall delay
		acall delay
	
		;Put cursor on first row,1 column
		mov a,#81h
		acall lcd_command
		acall delay
		
		acall readNibble ; read the nibble from P1.0 to P1.3, and check by reading after a delay
		anl a, #0fh ; mask the upper 4 bits
		swap a ; swap to make 0XH --> X0H
		mov r0, a ; move the address to R0
		
		; display first 4 bytes
		acall lcd_send4bytes
		
		;Put cursor on second row, 1 column
		mov a,#0C1h
		acall lcd_command
		acall delay

		; display 5th to 8th byte
		acall lcd_send4bytes

		; give a delay of about 5 seconds
		mov 4fh, #10
		acall my_delay

		; display the rest of bytes
		;Put cursor on first row,1 column
		mov a,#81h
		acall lcd_command
		acall delay

		; display 9th to 12th byte
		acall lcd_send4bytes
		
		;Put cursor on second row, 1 column
		mov a,#0C1h
		acall lcd_command
		acall delay

		; display the last 4 bytes
		acall lcd_send4bytes

		; display for five seconds
		mov 4fh, #10
		acall my_delay

		; repeat the whole routine
		jmp repeat

here: sjmp here				//stay here 

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay

         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay

         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;----------------------delay routine-----------------------------------------------------
delay:
	using 0
	push ar0
	push ar1
         mov r0,#1
loop2:	 mov r1,#255
loop1:	 djnz r1, loop1
		 djnz r0,loop2
		 pop ar1
		 pop ar0
		 ret

;---------------SUBROUTINE TO CONVERT BYTE TO ASCII---------------------------------------------
ASCIICONV:
	using 0
	push ar2
	push ar3
	MOV R2,A
	ANL A,#0Fh ;-- get the lower nibble by taking AND with 0FH
	MOV R3,A ;-- move the lower nibble to ACC
	SUBB A,#0Ah  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
	JNC ALPHA ;-- if carry is not set then the nibble was an alphabet

	MOV A,R3 ;-- else it was a digit, move the nibble to ACC
	ADD A,#30h   ;ADD 30H TO CONV HEX TO ASCII
	MOV B,A ;-- move the result to B
	JMP NEXT

	ALPHA: MOV A,R3  ;ADD 37H TO CONVERT ALPHABET TO ASCII
	ADD A,#37h
	MOV B,A ;-- move the result to B

	NEXT:MOV A,R2
	ANL A,#0F0h          ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET
	SWAP A
	MOV R3,A
	SUBB A,#0Ah
	JNC ALPHA2 

	MOV A,R3			;DIGIT TO ASCII
	ADD A,#30h
	pop ar3
	pop ar2
	RET

	ALPHA2:MOV A,R3
	ADD A,#37h          ;ALPHABET TO ASCII
	pop ar3
	pop ar2
	RET

;--------------------variable delay routine, reads D from 4fh and produces a delay of D/2 seconds---------------------
my_delay:
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

;----------------------------send the value of accumulator to lcd--------------------------------
lcd_sendacc:
	acall ASCIICONV
	acall lcd_senddata
	mov a, b
	acall lcd_senddata
	ret
	
;----------------------------read the nibble from port--------------------------------------------
readNibble :
	; Routine to read a nibble
	; First configure switches as input
	; To configure port as input, set it
	; Logic to read a 4 bit number (nibble)
	push ar0
	loop:
		mov p1, #0fh
		;read the input from switches (nibble)
		mov r0, p1 ;-- P1 is saved in R0
		;wait for one sec
		mov 4fh, #2
		lcall my_delay
		mov p1, #0fh
		;read the input from switches (nibble)
		mov a, p1 ;-- P1 is saved in R0
		xrl a, r0
		jnz loop
	mov a, r0 ;-- moving the previously read nibble to lower bits of 4EH
	pop ar0
	ret

;-----------------------a subroutine to display 4 consecutive bytes-------------------------------
; read consecutive 4 bytes starting from @R0 and display them using lcd_sendacc
; upon returning from the routine R0 --> R0 + 4
lcd_send4bytes:
	push ar2
	mov r2, #4 ; 4 bytes are displayed in a line
	loop_4b:
		mov a, @r0 ; load byte from location pointed by R0 to ACC
		acall lcd_sendacc ; display ACC on LCD
		mov a, #20h ; give a space
		lcall lcd_senddata
		inc r0
		djnz r2, loop_4b
	pop ar2
	ret

end