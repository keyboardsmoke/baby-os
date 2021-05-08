[org 0x7e00]

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
    lgdt [gdt_desc] ; load basic GDT descriptor
    mov eax, cr0 ; Read control register
    or eax, 1 ; Protected Mode Enable
    mov cr0, eax ; Write control register
    jmp codeseg:BOOTLOADER_EP32

%include "boot16/util.asm"
%include "boot32/boot32.asm"

extended_msg:
    db 'Entered extended boot sector... ',0

; GDT
gdt_nulldesc:
    dd 0
    dd 0

gdt_codedesc:
    dw 0xffff ; limit
    dw 0x0000 ; base1
    db 0x0000 ; base2
    db 10011010b ; access (Pr/Privl/S/Ex/DC/RW/Ac)
    db 11001111b ; flags (Gr/Sz) + Limit
    db 0x00

gdt_datadesc:
    dw 0xffff ; limit
    dw 0x0000 ; base1
    db 0x0000 ; base2
    db 10010010b ; access (Pr/Privl/S/Ex/DC/RW/Ac)
    db 11001111b ; flags (Gr/Sz) + Limit
    db 0x00

gdt_end:

gdt_desc:
    gdt_size: dw gdt_end - gdt_nulldesc - 1
    gdt_addr: dd gdt_nulldesc

codeseg equ gdt_codedesc - gdt_nulldesc
dataseg equ gdt_datadesc - gdt_nulldesc

times 2048-($-$$) db 0
