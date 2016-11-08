%include "print.asm"
%include "exit.asm"

%define start 200000001
%define end 300000001
%define mp_low 819475394029645
%define mp_high 0

section .text
	global _start

; rbp over flows at 18,446,744,073,709,551,615
_start:
    mov rbp, start          ; starting value
    mov rbx, end            ; ending value
    mov r12, mp_low         ; r12&r13 are record path lengths bits
    mov r13, mp_high        ; zero the high bits

.next:
    add rbp, 2

    cmp rbp, rbx          ; if i > rbx, j = i + 2
    ja .end

    ; set our 128bit values to i/j
    xor r15, r15        ; r,r/i - p0156
    mov r14, rbp          ; r/64,r/64 - p0156

    ; x += (x+1)>>1
    inc r14             ; r - p0156
    shr r14, 1          ; r,i - p06

    add r14, rbp          ; r,r/i - p0156
    adc r15, 0          ; r,r/i - 2p0156
    ;jc overflow        ; if adcx r15 sets cf to 1, end, third reg

.loop:
    ; todo store tzcnt in register and shrd/shr later
    tzcnt rcx, r14      ; r,r - p1 3l
    shrd r14, r15, cl   ; r,r,cl - p0156 3l 2c
    shr r15, cl

    cmp r15, 0          ; if second register is zero, r14 could be lower than i
    jne .continue
    cmp r14, rbp          ; lowest value in cycle
    jb .next            ; if lower than i, jump to inc

.continue:
    ; odd to unknown highest
    mov r8, r14
    mov r9, r15
    add r14, 1          ; x++
    adc r15, 0          ; add a carry flag
    shrd r14, r15, 1    ; x >> 1 ;
    shr r15, 1

    add r14, r8       ; x += a ; parity now unknown
    adc r15, r9
    ;jc overflow        ; end if carry to third register

    ; check for record
    cmp r15, r13
    jb .loop
    ja .record

    cmp r14, r12        ; else check lower bits
    jbe .loop

.record:
    mov r13, r15
    mov r12, r14
    mov rax, rbp
    jmp .loop

.end:
    print rax
    print r12
    print r13
    call _exit
