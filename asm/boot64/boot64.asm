[bits 64]
BOOTLOADER_EP64:
    ; mov edi, 0xb8000
    ; mov rax, 0x1f201f201f201f20
    ; mov ecx, 500
    ; rep stosq

    ; TODO: Even though '_start' is identical to StartEmu
    ; (I checked with IDA)
    ; it is faulting when trying to call it... linking issue? No idea.
    ; call _start

    call StartEmu

    jmp $

StartEmu:
    ; endbr64
    push    rbp
    mov     rbp, rsp
    mov     eax, 0x0B8000
    mov     dword [rax], 0x50505050
    nop
    pop     rbp
    ret

[extern _start]
