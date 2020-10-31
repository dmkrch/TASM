model small
.stack 100h
.data
rows dw 4
columns dw 4
size_of_element dw 2
array dw 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81
.code
start:
	mov ax, @data
	mov ds, ax
	mov es, ax

MODEL small

STACK 256

.data

;матрица размером 5x2

rows dw 5

cols dw 2

array dw 1,2,3,4,5,6,7,3,9,0

;это будет выглядеть так:

;array=

; {1 2}

; {3 4}

; {5 6}

; {7 3}

; {9 0}

elem dw 3 ;элемент для поиска

foundtime db 0 ;количество найденных элементов

.code

main:

mov ax,@data

mov ds,ax

mov si,0

mov cx, rows

external: ;внешний цикл по строкам

push cx ;сохранение в стеке счётчика внешнего цикла

mov cx, cols ;для внутреннего цикла (по столбцам)

internal: ;внутренний цикл по строкам

;сравниваем содержимое текущего элемента с искомым элементом:

mov ax,array[si]

cmp ax,elem

jne next

inc foundtime ; увеличиваем счётчик совпавших

array dw 1,2,3,4,5,6,7,3,9,0

next:

inc si ;передвижение на следующий элемент (2 bytes)

inc si

loop internal

pop cx ;восстанавливаем CX из стека

loop external ;цикл (внешний)

exit:

mov ax,4c00h

int 21h

end main

mov cx, rows

external: ;внешний цикл по строкам

push cx ;сохранение в стеке счётчика внешнего цикла

mov cx, cols ;для внутреннего цикла (по столбцам)

internal: ;внутренний цикл по строкам

mov ax,array[si]

call OUTPUT

mov dl, ‘ ‘

mov al, 2

int 21h

next:

inc si ;передвижение на следующий элемент (2 bytes)

inc si

loop internal

mov dl, 10

mov al, 2

int 21h

mov dl, 13

int 21h

pop cx ;восстанавливаем CX из стека

loop external ;цикл (внешний)	
	
	mov ah, 4ch
	int 21h
end start
