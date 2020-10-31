model small
.stack 100h
.data
line db 100 dup (?)
line_new db 150 dup (?)
line_length db 100
new_line_length db 150


vowels_array db 65, 69, 73, 79, 85, 89, 97, 101, 105, 111, 117, 121
vowels_arr_len db 12

symbol_status db (?)

.code

;function inputs string. si points to begin of input line. cx has line length
Input_line proc
	push bx
	push cx
	push ax
	push si
	push di

;using bx as an additional counter. cx has line length
	xor bx, bx
lp1:
	cmp cx, 3
	je put_enter	

	xor ax, ax
	mov ah, 01h
	int 21h
		
	cmp al, 13	
	jne not_enter
put_enter:
	mov al, 10
	stosb
	mov al, 13
	stosb
	mov al, '$'
	stosb	
	jmp end_lp1

not_enter:	
	stosb
	dec cx	
	jmp lp1	
end_lp1:	
	pop di
	pop si
	pop ax
	pop cx
	pop bx
	ret
Input_line endp






;function reads symbol from al. Sets variable to:
;0 - not a letter, 1 - vowel, 2 - consonant
Vowel_Or_Consonant proc
	push ax
	push cx
	push di

	cld
	mov cl, [vowels_arr_len]
	lea di, vowels_array

	repne scasb
	je is_vowel
	
	;now we know that our symbol is not vowel. We need to check if it is in 'letter' diaposon. If so, - 
	;it is consonant. If not - symbol is not a letter
	
	;( al >= 64 && al <= 90) || (al >= 97 && al  <= 122)
	cmp al, 64
	jl not_letter
	cmp al, 90
	jg next_comp
	jmp is_consonant

next_comp:	
	cmp al, 97
	jl not_letter
	cmp al, 122
	jg not_letter
is_consonant:
	mov [symbol_status], 2
	jmp end_procedure
not_letter:
	mov [symbol_status], 0
	jmp end_procedure
is_vowel:
	mov [symbol_status], 1

end_procedure:	
	pop di
	pop cx
	pop ax
	ret
Vowel_Or_Consonant endp		




;main function
start:
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	lea di, line	
	xor cx, cx
	mov cl, [line_length]

	call Input_line

	xor cx, cx
	mov cx, 1	
	lea di, line_new
loop1:	
	lea si, line
	add si, cx
	dec si
	xor ax, ax
	lodsb
	cmp al, 10
	je end_loop1	

	mov al, cl
	mov bl, 2
	div bl 

	;mov ax, cx
	;mov bx, 2
	;div bx
	
	cmp ah, 1
	je odd_index
	even_index:
		lea si, line
		add si, cx
		dec si
		xor ax, ax
		lodsb
		; now in al - code of each symbol
			
		call Vowel_Or_Consonant
	
		cmp symbol_status, 2
		je even_consonant 
		cmp symbol_status, 0
		je even_not_letter
		even_vowel:
			stosb
			jmp continue_loop1
		even_consonant:		
			stosb
			stosb
			jmp continue_loop1	
		even_not_letter:
			stosb
			jmp continue_loop1
	
	odd_index:
		lea si, line
		add si, cx
		dec si
		xor ax, ax
		lodsb
		; now in al - code of each symbol
		
		call Vowel_Or_Consonant
		
		cmp symbol_status, 2 
		je odd_consonant
		cmp symbol_status, 0
		je odd_not_letter
		odd_vowel:
			jmp continue_loop1
		odd_consonant:
			stosb
			jmp continue_loop1
		odd_not_letter:
			stosb
			jmp continue_loop1

continue_loop1:
	inc cx
	jmp loop1
end_loop1:
	mov al, 10
	stosb
	mov al, 13
	stosb
	mov al, '$'
	stosb		
	
	lea dx, line_new
	mov ah, 09h
	int 21h		
		
	mov ah, 4ch
	int 21h
end start
