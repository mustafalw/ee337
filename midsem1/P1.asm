org 00h
ljmp main

USING 0

; a subroutine which compares 3 numbers in R2, R3 and ACC and gives the smallest 2 of them
; under the condition that R2 is lesser than or equal to R3 and ACC can be any number
compare_3_ints:
	push ar4
	mov r4, a ; move ACC to R4 to save its contents
	clr c ; cleat C before subtraction
	subb a, r3 ; subtract R3 from ACC
	jnc return ; if carry is not set then ACC >== R3, in which case we don't need to change anything, so return
	mov a, r4 ; else check if ACC is smaller than R2 or not, so retrieve saved value of ACC again from R4
	clr c ; clear carry before subtraction
	subb a, r2 ; subtract R2 from ACC
	jc acc_is_smallest ; if carry is set then ACC < R2, in which case move R2 to R3 and ACC to R2
	mov r3, 4h ; ACC >= R2, in which case, just move ACC to R3
	jmp return ; and return
	acc_is_smallest:
		mov r3, 2h ; move R2 to R3
		mov r2, 4h ; move ACC to R2
		jmp return ; return
	return:
		pop ar4
		ret

findSmallest:
	push ar0
	push ar2
	push ar3
	push ar5
	; to use the above subroutine, we need to first check 50h and 51h
	; and store the smaller one in R2 and larger in R3
	mov a, 50h ; move 50H to ACC
	mov r2, 51h ; move 51H to R2
	clr c ; clear C before subtraction
	subb a, r2 ; subtract R2 from ACC i.e. 51H from 50H
	jc case1 ; if carry is set then (51H) > (50H), hence jump to case1 and do the needful
	mov r3, 50h ; else (50H) > (51H), in which case, just move 50H to R3
	jmp call_compare ; and jump to call_compare loop
	case1: 
		mov r2, 50h ; since (50H) is smaller, store 50H in R2
		mov r3, 51h ; 51H in R3
		jmp call_compare ; and jump to call_compare loop
	call_compare:
		mov r5, #3 ; R5 is the iterator and equal to 3 since 3 more comparisons are needed
		mov r0, #52h ; start reading from 52H
		loop:
			mov a, @r0 ; move @R0 to ACC since the compare_3_ints subroutine compares R2, R3 and ACC
			acall compare_3_ints ; call compare_3_ints to compare R2, R3 and ACC and store the smallest 2 of them in R2 & R3
			inc r0 ; increment R0
			djnz r5, loop
		mov 55h, r2 ; finally move the results from R2 and R3 to 55H and 56H respectively
		mov 56h, r3
	pop ar5
	pop ar3
	pop ar2
	pop ar0
	ret

main:
	; initialise
	mov 50h, #34
	mov 51h , #41
	mov 52h, #80
	mov 53h, #20
	mov 54h, #50
	acall findSmallest
	
stop: jmp stop

end