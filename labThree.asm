model small
.stack 100h
.data
firstN db "write first number: ", 10, 13, '$'
secondN db "write second number: ", 10, 13, '$'
errMsg db "overflow of number, try again", 10, 13, '$'
result db "sum = $"
ten dw 10	
sign db 0
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
	jnc notCary		; if carry flag is not set just continue work
	
	mov cx, 7
lp4:	call delete
	loop lp4
	
	mov ah, 09h
	lea dx, errMsg
	int 21h
	
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
	push cx
	push ax
	push bx

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

end_lp2:pop bx
	pop ax
	pop cx
	ret
output endp	

	

start:	mov ax, @data
	mov ds, ax

	;input of first number
	mov ah, 09h
	lea dx, firstN
	int 21h	
	call input		; now in bx - input number		
	
	push bx			; in stack - first number
;input of second number	
	mov ah, 09h
	lea dx, secondN
	int 21h
	call input 		; in bx - second number
;calculating sum of numbers
	pop ax			; in ax - first number
	add bx, ax		; in bx: first number + second number	

;printing result of sum
	mov ah, 09h
	lea dx, result
	int 21h
	call output		; outputting bx number	

	mov ah, 4ch
	int 21h

end start
