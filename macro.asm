%macro io 4
	mov rax,%1
	mov rdi,%2
	mov rsi,%3
	mov rdx,%4
	syscall	
%endmacro

section .data
	msg1 db "Enter your name: ",20H
	msg1len equ $-msg1
	msg2 db "Enter your name: ",20H
	msg2len equ $-msg2

section .bss
	nm resb 20
	len resb 1

section .code
	global _start
	_start:
		io 1,1,msg1,msg1len

		io 0,0,nm,20
		mov [len], rax

		io 1,1,msg2,msg2len

		io 1,1,nm,[len]

		mov rdx,60
		mov rdi,0
		syscall

