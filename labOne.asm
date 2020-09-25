model small
.stack 100h
.data
a dw 2
b dw 3
c dw 4
d dw 6

.code
start:	mov ax, @data
	mov ds, ax


	mov ax, [a]	; in ax - a
	mul [a]		; in ax - a^2
	
	push ax		; a^2	in stack	

	mov ax, [b]	; in ax - b
	mul [b]
	mul [b]		; in ax - b^3
		
	pop bx		; in bx - a^2 
	cmp bx, ax	; comparing a^2 and b^3
	jge bxLess	; if a^2 >= b^3 go bxLess
; if not - continue
	mov ax, [c]	; in ax - c
	mul [b]		; in ax - c * b
	push ax		; in stack - c * b
	
	mov ax, d	; in ax - d
	div b		; in ax - d / b
	
	pop bx		; in bx - c * b
	
	cmp ax, bx 	; comparing c * b and d / b
	je axEqbx	; if c*b == d/b go axEqbx
	
	mov ax, [a]	;
	or ax, [b]	; in ax - a OR b

; ax is ready, now we need to exit
	jmp result	
axEqbx:	mov ax, [a]	; in ax - a
	mul [a]		; in ax - a^2
	mul [a]		; in ax - a^3
	push ax		; in stack - a^3
	mov ax, [b]
	mul [b]		; in ax - b ^2
	push ax		; stack: 1) b^2 2) a^3
	mov ax, [c]
	mul [c]		; in ax - c^2
	mov bx, ax	; in bx - c ^2
	pop ax		; in ax - b^2
	sub ax, bx	; in ax - b^2 - c^2
	mov bx, ax	; in bx - b^2 - c^2
	pop ax		; in ax - a^3
	div bx		; in ax - a^3 / (b^2 - c^2)
	
	push ax		; in stack - a^3 / (...)
	mov ax, [b]
	mul [b]		; in ax - b^2
	add ax, 24	; in ax - b^2 + 24
	push ax		; in stack - 1) a^3 / (...) 2) b^2 + 24

	mov ax, [d]
	mul [d]		; in ax - d^2	
	mov bx, ax	; in bx - d^2
	
	pop ax		; in ax - b^2 + 24
	
	div bx		; in ax - (b^2 + 24) / d^2

	pop bx		; in bx - a^3 / (...)	
	add ax, bx	; in ax - a^3 / (b^2 - c^2) + (b^2+24)/d^2
	
	
; ax is ready, now we need to exit
	jmp result	; ax is ready, now we need to exit		
bxLess:	mov ax, [a]	; in ax - a
	mul [c]		; in ax - c * a
	sub ax, [b]	; in ax - c * a - b
; ax is ready	
result:	mov ah, 4ch

	int 21h
end start
