model small
.stack 100h
.data
array dw 50 dup(?)
rows dw (?)
columns dw (?)
array_size dw (?)
size_of_element dw 2
single_byte dw (?)
ten dw 10
sign dw 0
max_element dw (?)
min_element dw (?)
offset_si dw (?)
offset_bx dw (?)

file_output_name db "output.txt", 0
file_input_name db "input.txt", 0
file_open_fail_message db "Failed to open existing file", 10, 13, '$'
file_open_success_message db "File successfully opened", 10, 13, '$'
file_handle dw (?)
file_error_code dw (?)


.code	

; function opens file. It needs the following variables:
; 1. dx, that contains the offset of string with name
; 2. 'file_handle' that will contain file handle in case of success opening file.
; 3. 'file_error_code' will contain error code in case of failure to open file. If success - 0
Open_Existing_File proc
	push ax
	push bx
	
	mov ah, 3dh			; code of function that opens file
	mov al, 2			; 0 - read-only. 1 - write-only. 2-read\write
	int 21h	

	jc file_open_fail		; if carry flag is set - failed to open file
file_open_success:
	mov [file_handle], ax		; moving handle of file to variable 'file_handle'
	mov [file_error_code], 0
	jmp end_open

file_open_fail:		
	mov [file_error_code], ax 	; moving code of error to variable 'file_error_code'
	
end_open:
	pop bx
	pop ax
	ret
Open_Existing_File endp





; function closes opened file. It needs the following variables:
; 1. 'file handle' that contains file handle
Close_Opened_File proc
	mov ah, 3Eh
	mov bx, [file_handle]
	int 21h	
	ret
Close_Opened_File endp




; function reads from opened file next number. Puts this number to cx
 Read_Next_Number_From_File proc
	push ax
	push bx
	push dx
	push si
	push [sign]

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
	
	cmp [single_byte], 45
	jne next_comparison
	mov [sign], 1
	jmp continue_read_symbol_cycle


next_comparison:
	cmp [single_byte], 48
	jl symbol_not_digit
	cmp [single_byte], 57
	jg symbol_not_digit
	
	;here we know that symbol is digit
	mov bx, 10
	mov ax, cx
	mul bx
	sub [single_byte], 48
	add ax, [single_byte]
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
	cmp sign, 0
	je skip_negative_number_actions		; if sign == 0  -> number is positive
	neg cx

skip_negative_number_actions:	
	pop [sign]	
	pop si
	pop dx
	pop bx
	pop ax
	ret
Read_Next_Number_From_File endp





;function writes number from ax to file
Write_Number_To_File proc			
; 1. We need to know whether number is negative or positive. If negative - write '-' and neg it 
; 2. Then we divide number by 10 and push remainder to stack
; 3. Then we pop elements one by one and print them to file
	push ax
	push bx
	push cx
	push dx

; 1.
	test ax, ax
	jns number_is_ready
	neg ax

	push ax
	
	mov [single_byte], 45
	mov ah, 40h
	mov bx, [file_handle]
	mov cx, 1
	lea dx, single_byte
	int 21h
	
	pop ax
; 2.		
number_is_ready:
	xor cx, cx
loop_take_digits:
	xor dx, dx
	div [ten]				; in ax - number / 10
	push dx					; in stack - digits of number vice verca
	inc cx
	cmp ax, 0
	jnz loop_take_digits

; 3.
loop_write_digits_to_file:
	pop [single_byte]
	add [single_byte], '0'
	push cx
	mov ah, 40h
	mov bx, [file_handle]
	mov cx, 1
	lea dx, single_byte
	int 21h
	pop cx
	
	loop loop_write_digits_to_file
		
	pop dx
	pop cx
	pop bx
	pop ax
	ret
Write_Number_To_File endp



; function shows values in variable 'array', according to variables 'rows' and 'columns'
Show_Two_Dimensional_Array proc
	push ax
	push bx
	push cx	
	push dx
	push si
	push di
	
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

		mov bx, array[bx][si]
		call Show_Number
	
		mov dl, 32		; printing space 2 times
		mov ah, 02h	
		int 21h
		int 21h

		pop bx	
		pop cx	
		inc cx
		jmp loop_columns		
	loop_columns_end:		
	mov dx, 10			; printing new line symbol 2 times
	mov ah, 02h
	int 21h
	int 21h

	pop bx	
	inc bx
	jmp loop_rows

loop_end:	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
Show_Two_Dimensional_Array endp




; function prints number in bx
Show_Number proc
	push ax
	push bx
	push cx
	push dx
	
	xor cx, cx
	mov ax, bx
	
	test bx, bx			; if bx is negative
	jns lp2
	neg bx
	
	mov dl, 45
	mov ah, 02h	
	int 21h

	
	mov ax, bx

lp2:
	xor dx, dx
	inc cx
	div [ten] 			; in ax - number / 10
	push dx				; in stack - digits vice verca
	cmp ax, 0
	jnz lp2

lp3:	
	pop dx
	add dx, '0'
	mov ah, 02h
	int 21h

	loop lp3

end_lp2:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
Show_Number endp





start:
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	lea dx, file_input_name
	call Open_Existing_File 

	cmp [file_error_code], 0		; if code = 0 - file is succesfully opened
	;jne failed_to_open_input_file

	
file_opened:	
	; reading amount of elements to variable 'array_size'
	call Read_Next_Number_From_File	
	mov [array_size], cx

	;reading amount of rows to variable 'rows'	
	call Read_Next_Number_From_File
	mov [rows], cx

	; reading amount of columns to variable 'columns'	
	call Read_Next_Number_From_File
	mov [columns], cx


	; now reading numbers from file to our 2-dim-array
	mov cx, [array_size]
	lea di, array
loop_input_array:
	push cx
	call Read_Next_Number_From_File
	mov ax, cx
	pop cx
	stosw	
	loop loop_input_array
	; now we can close the file. everything is readed
	call Close_Opened_File





	; now we can do any actions we want with our 2-dim-array	
	call Show_Two_Dimensional_Array
	
	; here actions with columns
	mov bx, 0
	;jmp loop2_rows
loop1_rows:
	cmp bx, [columns]
	je loop1_end

	mov cx, 0
	push bx
	
	; calculatin offset of bx = size * bx (just counter)		
	mov ax, [size_of_element]
	mul bx
	mov bx, ax
	
	; moving first element of current column to 'max_element'	
	mov dx, array[bx][0]		
	mov [max_element], dx		

	loop1_columns:
		cmp cx, [rows]
		je loop1_columns_end
		; bx, cx are forbidden to use here. Or use push & pop to save the values 


		; calculating offset of si = size * columns * cx (just counter)
		mov ax, [size_of_element]
		mul [columns]
		mul cx	
		mov si, ax
		; now there are two offsets:   1) bx offset of j index   2) si offset of i index 	

		inc array[si][bx]		; incrementing element

		mov ax, array[si][bx]	
		cmp ax, [max_element]
		jle not_bigger
		; if current element is bigger than max_element.
		; 1. we move this max element to variable 'max_element'
		; 2. we move si offset to variable 'offset_si'
		; 3. we move bx offset to variable 'offset_bx'
		mov [max_element], ax
		mov [offset_si], si
		mov [offset_bx], bx

	not_bigger:
		inc cx
		jmp loop1_columns		
	loop1_columns_end:	
	; here we have max element of each column in variable 'max_element' and offsets in variables	
	mov si, [offset_si]
	mov bx, [offset_bx]	
	mov cx, [array_size]
	dec cx
	sub array[si][bx], cx

	pop bx	
	inc bx
	jmp loop1_rows

loop1_end:	



	; here actions with rows
	mov bx, 0
loop2_rows:
	cmp bx, [rows]
	je loop2_end

	mov cx, 0
	push bx
	
	; calculating offset of bx = size * bx (just counter) * rows	
	mov ax, [size_of_element]
	mul bx
	mul [columns]			
	mov bx, ax
	
	; moving first element of current row to 'min_element'	
	mov dx, array[bx][0]		
	mov [min_element], dx		

	loop2_columns:
		cmp cx, [columns]
		je loop2_columns_end
		; bx, cx are forbidden to use here. Or use push & pop to save the values 


		; calculating offset of si = size * cx (just counter)
		mov ax, [size_of_element]
		mul cx	
		mov si, ax
		; now there are two offsets:   1) bx offset of i index   2) si offset of j index 	

		dec array[bx][si]		; decrementing element

		mov ax, array[si][bx]	
		cmp ax, [min_element]
		jge not_less
		; if current element is bigger than max_element.
		; 1. we move this max element to variable 'max_element'
		; 2. we move si offset to variable 'offset_si'
		; 3. we move bx offset to variable 'offset_bx'
		mov [min_element], ax
		mov [offset_si], si
		mov [offset_bx], bx

	not_less:
		inc cx
		jmp loop2_columns		
	loop2_columns_end:	
	; here we have min element of each row in variable 'min_element' and offsets in variables	
	mov si, [offset_si]
	mov bx, [offset_bx]	
	mov cx, [array_size]
	dec cx
	add array[bx][si], cx

	pop bx	
	inc bx
	jmp loop2_rows

loop2_end:	
	; showing array on screen
	mov ah, 02h
	mov dl, 10
	int 21h
	int 21h	
	call Show_Two_Dimensional_Array






	; all actions with 2-dim-array done. Now we can write it to output file
	lea dx, file_output_name
	call Open_Existing_File
	; here we need to write array to file
	
	lea si, array
	mov cx, [array_size]
	mov bx, 1			; just counter for \n symbols
loop_write_file:
	lodsw				; in ax - number to write 
	call Write_Number_To_File
		
	; checking if this element is last in row	
	cmp bx, [columns]
	jne print_space

	push cx
	push bx

	; if last element of row we print '\n\n'
	mov ah, 40h
	mov [single_byte], 10
	mov bx, [file_handle]
	mov cx, 1
	lea dx, single_byte
	int 21h
	mov ah, 40h
	int 21h
	
	pop bx 
	pop cx

	mov bx, 0
	jmp continue_loop_write_file

	; if element is not last - just printing space	
print_space:
	push bx
	push cx

	mov [single_byte], ' '
	mov ah, 40h
	mov bx, [file_handle]
	mov cx, 1
	lea dx, single_byte
	int 21h
	mov ah, 40h
	int 21h
	
	pop cx	
	pop bx

continue_loop_write_file:
	inc bx	
	loop loop_write_file
	
	call Close_Opened_File	

end_prog:		
	mov ah, 4ch
	int 21h
end start
