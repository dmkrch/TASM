model small
.stack 100h
.data
nam db 10 dup (?)		; string for name
mesg db "Enter your name:$"	; input string
answ db 'Hello, !$            '	; output string
.code
start:	mov ax, @data
	mov ds, ax
	
	lea dx, mesg		; output input string 
	mov ah, 09h	
	int 21h			 

	xor cx, cx
	lea di, nam		; address of strg to di
lp:	mov ah, 01h		; reading symbol
	int 21h

	cmp al, 13		; if enter or not
        je l_quit		; if yes - quit the cycle
                
        mov [di], al   	 	; moving curr symbol to string 
        inc di          	; moving pointer to next symbol in string

        inc cx          	; amount of symbols in string
        jmp lp          	; again cycle
l_quit:	
; now we need to move $	
	lea si, answ		; in si - address of answer
	mov bl, [si + 8]	; bl contains symbol $		

	
	lea di, answ		; di = si	
	add di, 8		; di points to $
	add di, cx		; now points to free space 
	mov [di], bl		; moving symbol $ to free space
; now we need to move !	
	mov bl, [si + 7]	; now bl contains !
	lea di, answ
	add di, 7
	add di, cx
	mov [di], bl

; now we copy string 'nam' to answ + 7
	lea si, answ		; si points to begin of strg
	add si, 7		; si points to '!'
	lea di, nam		; di points to begin of name	 
	
	cmp cx, 0		; if user didnt input anything 
	jz quit
lp2:	mov bl, [di]		; bl contains next symbol from name
	mov [si], bl		; moving symbol from name to answ
	inc di	
	inc si
	loop lp2

quit:	lea dx, answ            ; prints output string 
        mov ah, 09h  
        int 21h


	xor al, al		; end
	mov ah, 4ch
	int 21h
end start
