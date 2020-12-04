CSEG segment 
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG 

org 80h             
    cmdLength db ?       ; length of cmd
    cmdLine db ?       	 ; cmd 
org 100h 

start: 
jmp Initialize


isActive db 0
Int_21h_vect dd ?
Int_40h_vect dd ?
msgAlreadyInstalled db 'ERROR: Already installed', 10, 13, '$'
msgCmdArgsErr db 'ERROR: Command line arguments are invalid', 10, 13, '$'
msgNotInstalled db 'ERROR: Not installed', 10, 13, '$'
msgUninstalled db 'SUCCESS: Uninstalled', 10, 13, '$'
msgInstalled db 'SUCCESS: Installed', 10, 13, '$'

 
Int_21h_proc proc 
    cmp ah, 9              
    je Ah_is_09
        jmp dword ptr cs:[Int_21h_vect] 
    Ah_is_09: 
        push dx
        push di
        push si
        push es
        push ds
        pop es

        mov isActive, 1

        mov	di, dx
        mov si, dx

	; main loop to change case of letters
        Loop1:
            lodsb
            cmp al, '$'
            je Finish
            cmp al, 'a'
            jl Next
            cmp	al, 'z'
            jg Ignore
            sub	al, 20h
            jmp Ignore
            Next:
                cmp al, 'A'
                jl Ignore
                cmp	al, 'Z'
                jg Ignore
                add	al, 20h
            Ignore:
                stosb
                jmp Loop1
        Finish:
        pushf             		 	;pushing flags      
        call dword ptr cs:[Int_21h_vect] 
        pop es
        pop si
        pop di
        pop dx                
    iret                   
int_21h_proc endp 



 
Int_40h_proc proc 
    cmp ah, 2
    je Ah_is_02
    jmp dword ptr cs:[Int_40h_vect] 
    Ah_is_02: 
        mov al, 1
        iret   
int_40h_proc endp




int_40h_empty proc
    iret
int_40h_empty endp




Initialize: 
    cmp byte ptr cmdLength, 0
    je ZeroArgs
    cmp byte ptr cmdLength, 3
    jne CmdError
    cmp byte ptr cmdLine[1],'-'
    jne CmdError
    cmp byte ptr cmdLine[2],'d'
    jne CmdError
    
    IsSlashD:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        jne ReturnPrev
        lea dx, msgNotInstalled
        jmp MessageAndExit

        ReturnPrev:
            mov ah,35h 
            mov al,40h 
            int 21h 

            mov word ptr Int_40h_vect,bx
            mov word ptr Int_40h_vect+2,es 

            mov ax, 2540h
            lea dx, int_40h_empty
            int 21h
            
            mov ah,35h 
            mov al,21h 
            int 21h 

            mov word ptr Int_21h_vect, bx
            mov word ptr Int_21h_vect+2, es 
        
            mov ax,2521h 
            lea dx, Int_21h_proc
            int 21h

            lea dx, msgUninstalled
            mov ah, 9
            int 21h
        
            lea dx, Initialize
            int 27h 

    ZeroArgs:
        xor al, al
        mov ah, 2
        int 40h
        cmp al, 0
        je Install
        lea dx, msgAlreadyInstalled
        jmp MessageAndExit

    CmdError:
        lea dx, msgCmdArgsErr
        jmp MessageAndExit
    
    Install:
        mov ah,35h 
        mov al,21h 
        int 21h 

        mov word ptr Int_21h_vect,bx
        mov word ptr Int_21h_vect+2,es 
        
        mov ah,35h 
        mov al,40h 
        int 21h 

        mov word ptr Int_40h_vect,bx
        mov word ptr Int_40h_vect+2,es 

        mov ax,2521h 
        lea dx, Int_21h_proc    
        int 21h 

        mov ax,2540h 
        lea dx, int_40h_proc    
        int 21h 
        
        mov ah, 9
        lea dx, msgInstalled
        int 21h
        
        lea dx, Initialize
        int 27h 			; running our program in residential mode
    
    MessageAndExit:
        mov ah, 9
        int 21h
        mov ax, 4c00h
        int 21h

    CSEG ends 
end start
