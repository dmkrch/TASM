.model small
.stack 100h
.data
string1 db "This is string for test", 10, 13, '$'
string2 db "My name is Dmitry and yours?", 10, 13, '$'
string3 db "WATCH OUT. This is dangerous", 10, 13, '$'
string4 db "hey, what do u want?", 10, 13, '$'

.code
start:
	mov ax, @data
	mov ds, ax
	mov es, ax

	mov ah, 09h
	lea dx, string1
	int 21h
	
	lea dx, string2
	int 21h
	
	lea dx, string3
	int 21h
	
	lea dx, string4
	int 21h
		
	mov ah, 4ch
	int 21h	
end start
