LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

org 0000h
ljmp main

org 000bh
timer_isr:
	inc r0 ; increment R0 to keep count of every 2ms
	mov tl0, #063h ; reset the values of TL0 and TH0
	mov th0, #0f0h
	mov a, r7 ; move R7 to ACC so as to compare with R1
	cjne a, 0h, continue_1 ; check if the R0 is equal to the switch input
	clr P3.0 ; if yes, then clear pin P1.4
	continue_1:
		cjne r0, #0fh, return ; check if R1 is 15
		mov r0, #000h ; if yes, then clear R0
		inc r1 ; increment R1 to keep count of every 30ms
		setb P3.0 ; set P1.4 at the start of every 30ms cycle
		cjne r7, #0, continue_2 ; check if input is 0
		clr P3.0 ; clear P1.4 in case input is 0
	continue_2:
		cjne r1, #033, return ; check if R1 is 33 i.e. 990ms
		mov p1, #00fh ; set the internal latches
		mov a, p1 ; read the value of the switches
		mov r7, a ; move the value to R7
		mov r1, #000h ; clear R1 to mark the start of the next 1 second cycle
		mov r2, tl1
		mov tl1, #000h
		lcall update_lcd
		return:
			reti

main:
	mov r0, #000h ; R0 counts every 2ms
	mov r1, #000h ; R1 counts every 30ms
	mov tmod, #041h ; run timer 0 in mode 1 and count pulses from photodetector on timer 1
	mov tl0, #063h ; fix TL0 and TH0 to get an interrupt every 2ms
	mov th0, #0f0h
	mov ie, #082h ; enable timer 0 interrupt
	setb tr0 ; start timer 0
	setb tr1 ; star external event counting on timer 1

	; initialise LCD
	
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
	mov dptr, #my_string1   ;Load DPTR with sring1 Addr
	acall lcd_sendstring	   ;call text strings sending routine

stop: jmp stop

;------------------------this subroutine updates the LCD-----------------------------------------------
update_lcd:
	; update switch value
	mov r3, 7h ; move the switch value to R3
	lcall bcd_conv ; call bcd_conv to convert R3 to decimal with ASCII stored in R5R4
	mov a, #0C0h ; Put cursor on second row, 0 column
	acall lcd_command
	mov a, r5
	lcall lcd_senddata
	mov a, r4
	lcall lcd_senddata
	
	; leave a space
	mov a, #20h
	lcall lcd_senddata
	
	; update RPM
	; first divide the count in R2 by 5 then double the remainder
	; then the quotient gives the 2 most significant digits and the
	; remainder (after doubling) gives the least significant digit
	; of the RPM in decimal
	mov a, r2
	mov b, #5
	div ab
	mov r6, b ; save the remainder in R6
	mov r3, a
	lcall bcd_conv
	mov a, r5
	lcall lcd_senddata
	mov a, r4
	lcall lcd_senddata
	mov a, r6 ; retrieve the remainder from R6
	mov b, #2
	mul ab
	add a, #30h
	lcall lcd_senddata
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

;------------------------Binary to BCD converter-----------------------------------------
; reads a byte from 3H and converts it into BCD
; the ASCII of ones place is in of 4H
; the ASCII of tens place is in 5H
; Important : this subroutine assumes that the
; decimal number has not more than 2 digits
; that is, the the number is not larger than 99 or 63H
bcd_conv:
	mov a, r3 ; move the byte from R3 to ACC
	mov b, #10
	div ab
	add a, #030h ; to convert to ASCII
	mov r5, a ; move the ASCII of tens digit to R5
	mov a, b
	add a, #030h ; to convert to ASCII
	mov r4, a ; move the ASCII of ones digit to R5
	ret

;;----------------------------send the value of accumulator to lcd--------------------------------
;lcd_sendacc:
	;acall ASCIICONV
	;acall lcd_senddata
	;mov a, b
	;acall lcd_senddata
	;ret

;------------- ROM text strings---------------------------------------------------------------

my_string1:
	DB   "IN RPM", 00H

end