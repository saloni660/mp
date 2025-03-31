%macro io 4
    mov rax, %1          ; System call number (1 for write, 0 for read)
    mov rdi, %2          ; File descriptor (1 for stdout, 0 for stdin)
    mov rsi, %3          ; Buffer address
    mov rdx, %4          ; Buffer size
    syscall              ; Invoke system call
%endmacro

section .data
    msg1 db "Number : "      ; Prompt message
    msg1len equ $-msg1       ; Message length
    endl db 10               ; Newline character
    pcount db 0              ; Positive count
    ncount db 0              ; Negative count

section .bss
    hexnum resq 5   ; Reserve space for 5 numbers (64-bit each)
    num1 resb 17    ; Reserve 17 bytes for user input
    temp resb 16    ; Temporary buffer for conversion

section .text
    global _start

_start:
    mov rcx, 5       ; Loop counter (5 numbers)
    mov rsi, hexnum  ; Point to storage array

nextnum:
    push rcx          ; Save loop counter
    push rsi          ; Save pointer to storage

    io 1, 1, msg1, msg1len  ; Print "Number : "
    io 0, 0, num1, 17       ; Read user input (16 hex chars)

    call ascii_hex           ; Convert ASCII hex to 64-bit value

    pop rsi           ; Restore pointer
    pop rcx           ; Restore loop counter

    mov [rsi], rbx    ; Store the number at `hexnum`
    add rsi, 8        ; Move to next memory slot (8 bytes)

    bt rbx, 63        ; Test the 63rd bit (MSB)
    jnc pcnt          ; If MSB = 0 (positive), jump to pcnt

    inc byte[ncount]  ; If negative, increment `ncount`
    loop nextnum      ; Repeat for next number

pcnt:
    inc byte[pcount]  ; If positive, increment `pcount`
    loop nextnum

mov rsi, hexnum
mov rcx, 5

next2:
    push rcx
    push rsi

    mov rbx, [rsi]
    call display

    pop rsi
    pop rcx
    add rsi, 8
    loop next2

io 1, 1, endl, 1
mov bl, [pcount]
call display8

io 1, 1, endl, 1
mov bl, [ncount]
call display8

mov rax, 60
mov rsi, 0
syscall

ascii_hex:
    mov rbx, 0
    mov rsi, num1
    mov rcx, 16

next:
    rol rbx, 4
    mov al, [rsi]
    cmp al, '9'
    jbe sub30h
    sub al, 7h

sub30h:
    sub al, 30h
    add bl, al
    inc rsi
    loop next
    ret

display:
    mov rsi, temp
    mov rcx, 16

next1:
    rol rbx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 9
    jbe add30h
    add al, 7h

add30h:
    add al, 30h
    mov [rsi], al
    inc rsi
    loop next1

    io 1, 1, temp, 16
    io 1, 1, endl, 1
    ret

display8:
    mov rsi, temp
    mov rcx, 2

next18:
    rol bl, 4
    mov al, bl
    and al, 0Fh
    cmp al, 9
    jbe add30h8
    add al, 7h

add30h8:
    add al, 30h
    mov [rsi], al
    inc rsi
    loop next18

    io 1, 1, temp, 2
    io 1, 1, endl, 1
    ret
