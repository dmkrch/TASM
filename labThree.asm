model small
.stack 100h
.data
a dw ?
b dw ?
c dw ?
d dw ?
firstN db "write a: ", 10, 13, '$'
secondN db "write b: ", 10, 13, '$'
thirdN db "write c: ", 10, 13, '$'
fourthN db "write d number: ", 10, 13, '$'
errMsg db "overflow of number, try again", 10, 13, '$'
result db "result = $"
zeroMsg db "can't divide by zero", 10, 10, '$'
ten dw 10	
sign db 0
limTop dw 32768


.code
; procedure that inputs number in bx
input proc	
	push ax
	push cx
	
	xor bx, bx
	xor cx, cx	

lp1:	mov ah, 01h
	int 21h			; in al - code of input symbol	
	
	cmp al, 13		; if symbol == enter -> exit
	je end_lp1
	
	cmp al, 45
	jne nextCmp
	mov [sign], al		; if '-' - moving to variable "sign"
	mov al, [sign]
	jmp contin
	

nextCmp:cmp al, 8		; if symbol == backspace	
	jne notBS
	
	mov dl, 32
	mov ah, 02h
	int 21h
	
	mov dl, 8
	int 21h
	
	mov ax, bx
	xor dx, dx
	div [ten]
	mov bx, ax
	jmp contin

notBS:	cmp al, 48
	jge bigger
	call delete
	jmp contin	
	
bigger:	cmp al, 57
	jle symbLes
	call delete 
	jmp contin
	
; if symbol 0-9
symbLes:mov cl, al		; in cl - code of symbol
	sub cl, '0'		; in cl - 0-9

	mov ax, bx		; in ax - bx
	mul [ten]		; in ax - bx * 10	
	jnc notCary1

notCary1:
	cmp ax, [limTop]
	jb notCary

	
	mov cx, 7
lp4:	call delete
	loop lp4
	
	call carry
	
	xor bx, bx
	jmp lp1
	
	
notCary:add ax, cx		; in ax - bx * 10 + cl	
	mov bx, ax		; in bx - new number	

contin:	jmp lp1
	
end_lp1:cmp sign, 0
	je endInpt
	neg bx			; making bx negative number	
endInpt:pop cx
	pop ax
	mov [sign], 0
	ret
input endp

; procedure that delets last symbol
delete proc
	mov dl, 8
	mov ah, 02h
	int 21h
	mov dl, 32
	int 21h
	mov dl, 8
	int 21h

	ret
delete endp

; procedure that outputs number in bx
output proc
	push ax
	push bx
	push cx
	push dx

	xor cx, cx
	mov ax, bx
	
	test bx, bx		; if bx is negative
	jns lp2			; if not - just printing number
	neg bx

	mov dl, 45
	mov ah, 02h
	int 21h


	mov ax, bx
	
		
lp2:	xor dx, dx
	inc cx
	div [ten]		; in ax - number / 10	
	push dx			; in stack - numbers of vice verca
	cmp ax, 0
	jnz lp2

	
lp3:	pop dx
	add dx, '0'
	mov ah, 02h
	int 21h

	loop lp3

end_lp2:pop dx
	pop cx
	pop bx	
	pop ax
	ret
output endp	

;procedure that printf error message if overflow
carry proc
	push ax
	push dx
	
	lea dx, errMsg
	mov ah, 09h
	int 21h
	
	pop dx
	pop ax

	ret
carry endp
	
start:	mov ax, @data
	mov ds, ax

;input of numbers
	lea dx, firstN
	mov ah, 09h
	int 21h
	call input
	mov [a], bx

	lea dx, secondN
	int 21h	
	call input		
	mov [b], bx
	
	lea dx, thirdN
	int 21h
	call input	
	mov [c], bx

	lea dx, fourthN
	int 21h
	call input
	mov [d], bx


;now calculating
	mov ax, [a]	; in ax - a
	imul [a]		; in ax - a^2

	jnc next
	call carry	; printf if overflow
	jmp ending
	
next:	push ax		; a^2	in stack	

	mov ax, [b]	; in ax - b
	imul [b]
	
	jnc next1
	call carry
	jmp ending

next1:	imul [b]		; in ax - b^3

	jnc next2
	call carry
	jmp ending
		
next2:	pop bx		; in bx - a^2 
	cmp bx, ax	; comparing a^2 and b^3
	jge bxLessF 	; if a^2 >= b^3 go bxLess
; if not - continkkue
	mov ax, [c]	; in ax - c
	imul [b]		; in ax - c * b

	jnc next3
	call carry
	jmp ending

next3:	push ax		; in stack - c * b
	
	mov ax, d	; in ax - d
	xor dx, dx
	cwd
	idiv b		; in ax - d / b
	
	pop bx		; in bx - c * b
	
	cmp ax, bx 	; comparing c * b and d / b
	je axEqbx	; if c*b == d/b go axEqbx
	
	mov ax, [a]	;
	or ax, [b]	; in ax - a OR b

; ax is ready, now we need to exit
	jmp finalRes
axEqbx:	mov ax, [a]	; in ax - a
	imul [a]		; in ax - a^2
	imul [a]		; in ax - a^3
	push ax		; in stack - a^3
	mov ax, [b]
	imul [b]		; in ax - b ^2
	push ax		; stack: 1) b^2 2) a^3
	mov ax, [c]
	imul [c]		; in ax - c^2
	mov bx, ax	; in bx - c ^2
	pop ax		; in ax - b^2
	sub ax, bx	; in ax - b^2 - c^2
	mov bx, ax	; in bx - b^2 - c^2

	cmp bx, 0
	jnz notZero
	lea dx, zeroMsg
	mov ah, 09h
	int 21h
	jmp ending

bxLessF:jmp bxLess

notZero:pop ax		; in ax - a^3
	xor dx, dx
	cwd
	idiv bx		; in ax - a^3 / (b^2 - c^2)
	
	push ax		; in stack - a^3 / (...)
	mov ax, [b]
	imul [b]		; in ax - b^2
	add ax, 24	; in ax - b^2 + 24
	push ax		; in stack - 1) a^3 / (...) 2) b^2 + 24

	mov ax, [d]
	imul [d]		; in ax - d^2	
	mov bx, ax	; in bx - d^2
	
	pop ax		; in ax - b^2 + 24

	xor dx, dx
	cwd
	idiv bx		; in ax - (b^2 + 24) / d^2

	pop bx		; in bx - a^3 / (...)	
	add ax, bx	; in ax - a^3 / (b^2 - c^2) + (b^2+24)/d^2
	
	
; ax is ready, now we need to exit
	jmp finalRes	; ax is ready, now we need to exit		
bxLess:	mov ax, [a]	; in ax - a
	imul [c]		; in ax - c * a
	sub ax, [b]	; in ax - c * a - b
; ax is ready	
finalRes:
	mov bx, ax

	lea dx, result
	mov ah, 09h
	int 21h

	call output
ending:	mov ah, 4ch
	int 21h
end start
