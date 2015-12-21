org 0000h
ljmp main

main:
	mov r1, #16
	mov r2, #083h
	mov r3, #004h
	mov r4, #000h
	mov r5, #000h
	mov r6, #000h
	loop:
		mov a, r3
		rlc a
		mov r3, a ; save ACC in R3
		mov a, r4
		addc a, r4
		da a
		mov r4, a
		mov a, r5
		addc a, r5
		da a
		mov r5, a
		mov a, r6
		addc a, r6
		da a
		mov r6, a
		cjne r1, #9, continue
		mov r3, 2h
		continue:
			djnz r1, loop

stop: jmp stop

end