%define SYS_EXIT 60

_exit:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
