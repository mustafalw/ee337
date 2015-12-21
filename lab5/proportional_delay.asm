org 0
ljmp main

; a subroutine to generate delay proportional to the
; 16 bit number stored in the registers 81H/82H in
; the indirectly addressable memory
proportional_delay:
	mov r0, #81h ; write immediate value 81H in register R0
	mov a, @r0 ; read the value stored @81H
	; take 2's complement of the 16 bits
	cpl a ; complement the byte read
	setb c ; set the carry bit
	addc a, #00h ; add 1 to the 1's complement
	mov tl0, a ; move ACC to TL0
	inc r0 ; increment R0 to address next bit
	mov a, @r0 ; read the value stored @81H
	cpl a ; complement the byte read
	addc a, #00h ; add the carry bit from the previous addition
	mov th0, a ; move ACC to TH0
	mov tmod, #1 ; set timer 0 in mode 1
	setb tr0 ; start timer 0
	again:
		jnb tf0, again ; poll the TF0 bit
	clr tr0
	clr tf0
	ret

main:
	mov r0, #81h
	mov @r0, #00h
	inc r0
	mov @r0, #08h
	acall proportional_delay

stop: sjmp stop

end