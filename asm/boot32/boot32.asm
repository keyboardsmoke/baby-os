[bits 32]

[extern BOOTLOADER_EP64]

extern codeseg
extern dataseg

%include "boot32/util.asm"

global BOOTLOADER_EP32
BOOTLOADER_EP32:
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call EVGA_CLEAR_SCREEN32

    ; Set 32-bit global stack space
    ; mov ebp, addr
    ; mov esp, ebp

    ; Check that the CPUID instruction is supported
    call BOOTLOADER_CHECK_CPUID
    cmp eax, 0
    jne CPUIDError

    ; Check that 64-bit long mode is supported
    call CHECK_LONGMODE32
    cmp eax, 0
    jne LongModeError

    push WaitingToTransitionString
    call EVGA_PRINT_ERROR32

    ; Attempt to setup paging for long mode transition
    call SETUP_PAGING32

    ; Set the long mode MSR
    call ENABLE_LONGMODE32

    ; Enable paging
    call ENABLE_PAGING32

    ; Setup long mode (64-bit) GDT
    call SetupLongModeGDT

    ; Transition to 64-bit long mode
    jmp codeseg:BOOTLOADER_EP64

CPUIDError:
    push CPUIDErrorString
    call EVGA_PRINT_ERROR32
    hlt

LongModeError:
    push LongModeErrorString
    call EVGA_PRINT_ERROR32
    hlt

WaitingToTransitionString:
    db 'Waiting to transition to long mode...',0

CPUIDErrorString:
    db 'CPUID instruction not supported. ',0

LongModeErrorString:
    db 'Long mode not supported. ',0
