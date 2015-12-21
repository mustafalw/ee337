org 00h
ljmp main

main:
	mov p1, #0fh ;-- set up the internal latches from P1.0 to P1.3 to high
	mov a, p1 ;-- read the pins of port P1
	mov r0, a
	rr a
	xrl a, r0
	orl a, #0f0h
	swap a
	mov p1, a
	jmp main
	
stop: jmp stop

end