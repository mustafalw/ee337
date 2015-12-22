org 00h
ljmp main

matMult:
	; calculate C = AB, where A, B and C are 2x2 matrices
	; A is stored from 50H to 53H
	; B is stored from 55H to 58H
	; C is to be stored in 60H to 63H
	;calculating c11
	mov a, 50h
	mov b, 55h
	mul ab
	mov r2, a
	mov a, 51h
	mov b, 57h
	mul ab
	add a, r2
	mov 60h, a
	;calculating c12
	mov a, 50h
	mov b, 56h
	mul ab
	mov r2, a
	mov a, 51h
	mov b, 58h
	mul ab
	add a, r2
	mov 61h, a
	;calculating c21
	mov a, 52h
	mov b, 55h
	mul ab
	mov r2, a
	mov a, 53h
	mov b, 57h
	mul ab
	add a, r2
	mov 62h, a
	;calculating c22
	mov a, 52h
	mov b, 56h
	mul ab
	mov r2, a
	mov a, 53h
	mov b, 58h
	mul ab
	add a, r2
	mov 63h, a
	ret

main:
	; initialise
	mov 50h, #7
	mov 51h, #7
	mov 52h, #7
	mov 53h, #7
	mov 55h, #1
	mov 56h, #2
	mov 57h, #3
	mov 58h, #4
	acall matMult

stop: jmp stop

end