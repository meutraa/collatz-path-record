%define SYS_WRITE 1
%define stdout 1

%macro print 1
    mov qword [reg + 0], %1
    call _print
%endmacro

section .bss
    save resq 8
    reg resq 1

section .text

_print:
    ; save registers
    mov qword [save + 0], rax
    mov qword [save + 8], rcx
    mov qword [save + 16], rdx
    mov qword [save + 24], rdi
    mov qword [save + 32], rsi
    mov qword [save + 40], r10
    mov qword [save + 48], r11
    mov qword [save + 56], r12

    ; begin print
    mov rax, qword [reg + 0]
    mov rcx, 10
    mov r12, 2
    push word ' '

.div:
    xor rdx, rdx
    div rcx
    add rdx, '0'
    push word dx
    add r12, 2
    cmp rax, 0
    jne .div
    
    mov rdx, r12 
    mov rax, SYS_WRITE
    mov rdi, stdout
    mov rsi, rsp
    syscall
    add rsp, r12

    ; load registers
    mov rax, qword [save + 0]
    mov rcx, qword [save + 8]
    mov rdx, qword [save + 16]
    mov rdi, qword [save + 24]
    mov rsi, qword [save + 32]
    mov r10, qword [save + 40]
    mov r11, qword [save + 48]
    mov r12, qword [save + 56]
ret
