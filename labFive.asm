model small
.stack 100h
.data
rows dw 4
columns dw 3
size_of_element dw 2
array dw 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81
.code
start:
	mov ax, @data
	mov ds, ax
	mov es, ax

	mov bx, 0
loop_rows:
	cmp bx, [rows]
	je loop_end

	push bx
	mov cx, 0
	loop_columns:
		cmp cx, [columns]
		je loop_columns_end
		
		;here we have bx - index i and cx - index j in arr(i, j)
		;so we push these values to be sure we wont lose them after some actions
		push cx
		push bx
			
		mov ax, [size_of_element]
		mul [columns]
		mul bx
		mov bx, ax
		; now bx is ready (offset i)
		
		mov ax, [size_of_element]
		mul cx
		; now ax is ready (offset j)		

		mov si, ax

		mov dx, array[bx][si]
		mov ah, 02h
		int 21h
	
		pop bx	
		pop cx	
		inc cx
		jmp loop_columns		
	loop_columns_end:		
	mov dx, 10
	mov ah, 02h
	int 21h
	mov dx, 13
	int 21h

	pop bx	
	inc bx
	jmp loop_rows
loop_end:
		
	mov ah, 4ch
	int 21h
end start
