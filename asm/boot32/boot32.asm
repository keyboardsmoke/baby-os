[bits 32]

BOOTLOADER_EP32:
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call BOOTLOADER_EVGA_CLEAR_SCREEN

    ; Set 32-bit global stack space
    ; mov ebp, addr
    ; mov esp, ebp

    ; CPUID/upgrade to 64-bit mode
    call BOOTLOADER_CHECK_CPUID
    cmp eax, 0
    jne CPUIDError

    ; Attempt to go into long mode

    jmp $

CPUIDError:
    push CPUIDErrorString
    call BOOTLOADER_EVGA_PRINT_ERROR
    hlt

LongModeError:
    push LongModeErrorString
    call BOOTLOADER_EVGA_PRINT_ERROR
    hlt

CPUIDErrorString:
    db 'CPUID instruction not supported. ',0

LongModeErrorString:
    db 'Long mode not supported. ',0

%include "boot32/util.asm"
%include "boot64/boot64.asm"
