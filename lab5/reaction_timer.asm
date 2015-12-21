LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0
LJMP MAIN

ORG 000BH ;ISR address for Timer 0
	INC R0 ;To keep the count of no. of times timer as overflown
	RETI

ORG 200H
MAIN:
	BACK: LCALL DISPLAY_MSG1
	LCALL START_TIMER
	LCALL DISPLAY_MSG2
	mov 4fh, #10
	lcall my_delay
	SJMP BACK
	HERE: SJMP HERE

DISPLAY_MSG1:
	mov P2,#00h
	mov P1,#00h
  ;initial delay for lcd power up
	acall delay
	acall delay

	acall lcd_init      ;initialise LCD
	
	acall delay
	acall delay
	acall delay
	mov a,#80h		 ;Put cursor on first row,0 column
	acall lcd_command	 ;send command to LCD
	acall delay
	mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	acall lcd_sendstring	   ;call text strings sending routine
	acall delay

	mov a,#0C2h		  ;Put cursor on second row,2 column
	acall lcd_command
	acall delay
	mov   dptr,#my_string2
	acall lcd_sendstring
	ret
	
START_TIMER:
	; Configures TMOD,(for 16 bit mode)
	mov tmod, #01h
	mov tl0, #00h
	mov th0, #00h
	; Set IE correctly and actions on timer overflow should be
	; written in Interrupt Service Routine address.
	mov ie, #82h
	; Switch on LED
	setb p1.4
	;Starts Timer (Set TR0)
	setb tr0
	;Wait for switch to go off.
	mov p1, #11h
	again:
		mov a, p1
		jnb acc.0, again
	; Clear TR0 to stop timer.
	clr tr0
	ret
	
DISPLAY_MSG2:
	; Displays second msg
	 mov P2,#00h
	 mov P1,#00h
	  ;initial delay for lcd power up

     acall delay
	 acall delay

	 acall lcd_init      ;initialise LCD
	 acall delay
	 acall delay
	 acall delay
	 mov a,#81h		 ;Put cursor on first row,0 column
	 acall lcd_command	 ;send command to LCD
	 acall delay
	 mov   dptr,#my_string3   ;Load DPTR with sring1 Addr
	 acall lcd_sendstring	   ;call text strings sending routine
	 acall delay

	 mov a,#0C0h		  ;Put cursor on second row,2 column
	 acall lcd_command
	 acall delay
	 mov   dptr,#my_string4
	 acall lcd_sendstring
	  
	 mov a, r0 ; loading the value of R3 in ACC
	 acall lcd_sendacc
		
	 mov a, th0 ;-- loading the value of R4 in ACC
	 acall lcd_sendacc
		
	 mov a, tl0 ;-- loading the initial value of R5 in ACC
	 acall lcd_sendacc
		  
	 ret
	
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

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
         clr   a                 ;clear Accumulator for any previous data
         movc  a,@a+dptr         ;load the first character in accumulator
         jz    exit              ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   dptr              ;increment data pointer
         sjmp  LCD_sendstring    ;jump back to send the next character
exit:
         ret                     ;End of routine

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

;----------------------------send the value of accumulator to lcd--------------------------------
lcd_sendacc:
	acall ASCIICONV
	acall lcd_senddata
	mov a, b
	acall lcd_senddata
	ret

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

;------------- ROM text strings---------------------------------------------------------------

my_string1:
         DB   "PRESS SWITCH SW1", 00H
my_string2:
		 DB   "AS LED GLOWS", 00H
my_string3:
         DB   "REACTION TIME", 00H
my_string4:
		 DB   "COUNT IS ", 00H
end
