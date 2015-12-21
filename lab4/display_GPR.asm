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
	mov a, #01h
	mov b, #0ffh
	mov psw, #067h
	mov r0, #01ah
	mov r1, #043h
	mov r2, #0ebh
	mov r3, #091h
	mov r4, #059h
	mov r5, #04fh
	mov r6, #02eh
	mov r7, #0d8h
	mov sp, #0cfh

	;since ACC, B, SP and PSW are used in the program and keep on changing, save them on stack
	push sp
	push psw
	push b
	push acc
	
	;initial delay for lcd power up
    mov P2,#00h
	mov P1,#00h

	;initialise LCD
    acall delay
	acall delay
	acall lcd_init
	acall delay
	acall delay
	acall delay

	;Put cursor on first row,0 column
	mov a,#80h		 
	acall lcd_command ; send command to LCD
	acall delay
	mov dptr, #my_string1 ; load DPTR with mysring1 address
	acall lcd_sendstring ; call text strings sending routine
	acall delay

	pop acc ; retrieve the initial value of ACC from stack
	acall lcd_sendacc ; call lcd_sendacc, a subroutine to display ACC on LCD
	
	mov a, #20h ; write blank space character
	acall lcd_senddata

	pop acc ; retrieve the initial value of B from stack
	acall lcd_sendacc
	
	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	pop acc ; retrieve the initial value of PSW from stack
	acall lcd_sendacc

	; put cursor on second row, 0 column
	mov a,#0C0h
	acall lcd_command
	acall delay
	mov   dptr,#my_string2 ; load DPTR with mysring2 address
	acall lcd_sendstring

	mov a, r0 ; loading the value of R0 in ACC
	acall lcd_sendacc

	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	mov a, r1 ;-- loading the value of R1 in ACC
	acall lcd_sendacc

	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	mov a, r2 ;-- loading the value of R2 in ACC
	acall lcd_sendacc

	mov 4fh, #10 ; delay of 5 seconds, store D = 10 in 4FH to get a delay of D/2
	acall my_delay

	mov a, #01h ; clear lcd before displaying the next set of registers
	acall lcd_command

	; put cursor on first row, 0 column
	acall delay
	acall delay
	acall delay
	mov a,#80h		 
	acall lcd_command
	acall delay
	mov dptr, #my_string3 ; load DPTR with mysring3 address
	acall lcd_sendstring ; call text strings sending routine
	acall delay

	mov a, r3 ; loading the value of R3 in ACC
	acall lcd_sendacc

	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	mov a, r4 ;-- loading the value of R4 in ACC
	acall lcd_sendacc

	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	mov a, r5 ;-- loading the initial value of R5 in ACC
	acall lcd_sendacc
	
	; put cursor on second row, 0 column
	mov a,#0C0h
	acall lcd_command
	acall delay
	mov   dptr,#my_string4 ; load DPTR with mysring4 address
	acall lcd_sendstring

	mov a, r6 ;-- loading the value of R6 in ACC
	acall lcd_sendacc

	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	mov a, r7 ;-- loading the value of R7 in ACC
	acall lcd_sendacc

	mov a, #20h ; write blank space character
	acall lcd_senddata
	
	pop acc ; retrieve the initial value of SP from stack
	acall lcd_sendacc

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
;generates a delay of about 260us
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

;------------- ROM text strings---------------------------------------------------------------
my_string1:
         DB   "ABPSW = ", 00H
my_string2:
         DB   "R012  = ", 00H
my_string3:
         DB   "R345  = ", 00H
my_string4:
         DB   "R67SP = ", 00H
end
	