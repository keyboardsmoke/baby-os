; [org 0x7e00]

[bits 16]

mov bx, extended_msg
call BOOTLOADER_PRINT
call BOOTLOADER_UPGRADE32

BOOTLOADER_ENABLEA20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

BOOTLOADER_UPGRADE32:
    call BOOTLOADER_ENABLEA20
    cli ; disable interrupts
    lgdt [gdt_descriptor] ; load basic GDT descriptor
    mov eax, cr0 ; Read control register
    or eax, 1 ; Protected Mode Enable
    mov cr0, eax ; Write control register
    jmp codeseg:BOOTLOADER_EP32

extended_msg:
    db 'Entered extended boot sector... ',0

%include "boot16/util.asm"
%include "boot32/boot32.asm"
%include "gdt.asm"

times 2048-($-$$) db 0
