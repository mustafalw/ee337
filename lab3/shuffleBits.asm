org 00h
ljmp main

shuffleBits:
	using 0
	push ar0 ;-- pushing the registers being used in this program
	push ar1
	push ar2
	mov r2, 50h ;-- R2 = the value of K i.e. the number of elements in the array
	mov r0, 51h ;-- R0 = pointer to the first array starting
	mov r1, 52h ;-- R1 = pointer to the second array starting
	dec r2 ;-- the loop runs only till K-1 since the Kth case needs to handled separately
	loop_shuffle:
		mov a, @r0 ;-- ACC = @R0
		inc r0 ;-- R0 = R0 + 1
		xrl a, @r0 ;-- ACC = ACC^@R0
		mov @r1, a ;-- @R1 = ACC
		inc r1 ;-- R1 = R1 + 1
		djnz r2, loop_shuffle
	mov a, @r0 ;-- ACC = A[K-1]
	mov r0, 51h ;-- R0 = the starting address of the array A
	xrl a, @r0 ;-- ACC = ACC^A[0]
	mov @r1, a ;-- moving ACC to the specified location
	pop ar2 ;-- popping the registers before returning
	pop ar1
	pop ar0
	ret

main:
	mov 50h, #5 ;-- the size of array A
	mov 51h, #60h ;-- starting address of array A
	mov 52h, #70h ;-- starting address of array B
	MOV 60H, #0F0H
	MOV 61H, #0A1H
	MOV 62H, #0B2H
	MOV 63H, #0C3H
	MOV 64H, #0D4H
	lcall shuffleBits

stop: jmp stop

end