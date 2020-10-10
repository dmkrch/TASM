model small
.stack 100h
.data
vowel_message db "number is vowel", 10, 13, '$'
consonant_message db "number is consonant", 10, 13, '$'

vowels_array db 65, 69, 73, 79, 85, 89, 97, 101, 105, 111, 117, 121
vowels_arr_len db 12

.code
Vowel_Or_Consonant proc
	cld
	mov cx, 12
	lea di, vowels_array
	rep scasb		
	
	mov dl, [di]
	mov ah, 02h
	int 21h
	
	ret
Vowel_Or_Consonant endp		



start:
	mov ax, @data
	mov ds, ax

	xor ax, ax
	mov al, [vowels_array + 5] ; moving to 5th vowel symbol to al

	call Vowel_Or_Consonant
	
	mov ah, 4ch
	int 21h
end start

