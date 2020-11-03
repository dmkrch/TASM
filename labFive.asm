model small
.stack 100h
.data
rows dw 4
columns dw 3
array dw 50 dup(?)
array_size dw (?)
size_of_element dw 2
single_byte db (?)
line_for_read db 30 dup(?)


file_name db "input.txt", 0
file_open_fail_message db "Failed to open existing file", 10, 13, '$'
file_open_success_message db "File successfully opened", 10, 13, '$'
file_handle dw (?)
file_error_code dw (?)


.code	

; function opens file. It needs the following variables:
; 1. 'file_name' that contains name of file
; 2. 'file_handle' that will contain file handle in case of success opening file.
; 3. 'file_error_code' will contain error code in case of failure to open file. If success - 0
Open_Existing_File proc
	push ax
	push bx
	push dx
	
	mov ah, 3dh			; code of function that opens file
	mov al, 0			; 0 - read-only. 1 - write-only. 3-read\write
	lea dx, file_name		; address of string with file name
	int 21h	

	jc file_open_fail		; if carry flag is set - failed to open file
file_open_success:
	mov [file_handle], ax		; moving handle of file to variable 'file_handle'
	mov [file_error_code], 0
	jmp end_open

file_open_fail:		
	mov [file_error_code], ax 	; moving code of error to variable 'file_error_code'
	
end_open:
	pop dx	
	pop bx
	pop ax
	ret
Open_Existing_File endp





; function reads from opened file next number. Puts this number to ax
Read_Next_Number_From_File proc
	xor cx, cx			; we will use cx for readed number
read_symbol_cycle:
	push cx
	
	mov bx, [file_handle]		; file handle to bx
	lea dx, single_byte		; offset of single byte to dx
	mov ah, 3fh			; code of function to ah
	mov cx, 1			; 1 byte to read from file
	int 21h	
	; now in single_byte next symbol from file	

	pop cx

	cmp [single_byte], 48
	jl symbol_not_digit
	cmp [single_byte], 57
	jg symbol_not_digit
	
	;here we know that symbol is digit
	mov bx, 10
	mov ax, cx
	mul bx
	sub [single_byte], 48
	add al, [single_byte]
	mov cx, ax
	;now in cx - cx * 10 + digit
	jmp continue_read_symbol_cycle

symbol_not_digit:
	cmp cx, 0
	jne end_read_symbol_cycle		; if cx != 0 - end of cycle
	jmp continue_read_symbol_cycle		; if cx == 0 - continue reading
continue_read_symbol_cycle:
	mov ax, 4406h
	mov bx, [file_handle]
	int 21h					; calling function to check for eof
	cmp al, 0
	je end_read_symbol_cycle		; if cl == 0 - end of file
	
	jmp read_symbol_cycle			; if not end of file - continue reading

end_read_symbol_cycle:
	ret
Read_Next_Number_From_File endp





start:
	mov ax, @data
	mov ds, ax
	mov es, ax

	jmp loop_end

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
		mov si, ax
		; now si is ready (offset j)		

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
	call Open_Existing_File 

	cmp [file_error_code], 0
	jne failed_to_open
	
	lea dx, file_open_success_message
	mov ah, 09h
	int 21h

file_opened:	
	call Read_Next_Number_From_File	
	mov [array_size], cx
	
	call Read_Next_Number_From_File
	mov [rows], cx
	
	call Read_Next_Number_From_File
	mov [columns], cx

	jmp end_prog
failed_to_open:	
	lea dx, file_open_fail_message
	mov ah, 09h
	int 21h
		
	mov dx, [file_error_code]
	add dx, 48
	mov ah, 02h
	int 21h

end_prog:		
	mov ah, 4ch
	int 21h
end start
