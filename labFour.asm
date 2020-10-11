model small
.stack 100h
.data
vowel_message db "letter is vowel", 10, 13, '$'
consonant_message db "letter is consonant", 10, 13, '$'
not_symbol_message db "not a letter", 10, 13, '$'

vowels_array db 65, 69, 73, 79, 85, 89, 97, 101, 105, 111, 117, 121
vowels_arr_len db 12

symbol_status db (?)

.code
Vowel_Or_Consonant proc
	cld
	mov cl, [vowels_arr_len]
	lea di, vowels_array

	repne scasb
	je is_vowel
	
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
	lea dx, consonant_message
	mov ah, 09h
	int 21h
	jmp end_procedure
not_letter:
	lea dx, not_symbol_message
	mov ah, 09h
	int 21h
	jmp end_procedure
is_vowel:
	dec di
	lea dx, vowel_message
	mov ah, 09h
	int 21h
end_procedure:	
	ret
Vowel_Or_Consonant endp		



start:
	mov ax, @data
	mov ds, ax
	mov es, ax

	xor ax, ax
	mov ah, 01h
	int 21h
	
	call Vowel_Or_Consonant
	
	mov ah, 4ch
	int 21h
end start

