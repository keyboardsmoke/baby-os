[org 0x7c00]

mov [BOOT_DISK], dl

mov bp, 0x7c00
mov sp, bp

; Just print the basic intro
mov bx, introstring
call BOOTLOADER_PRINT

; Load additional sectors to use
call BOOTLOADER_READ_SECTORS
cmp ah, 0x00 ; return code
je sectors_loaded
mov bx, sector_load_failed
call BOOTLOADER_PRINT
hlt

sectors_loaded:
jmp POSTBOOT_AREA

%include "boot16/util.asm"
%include "boot16/disk.asm"

sector_load_failed:
    db 'Failed to load additional sectors from disk. ',0

introstring:
    db 'Running baby-os... ',0

; Fill the remaining bootloader space (must be 512) with 0s
times 510-($-$$) db 0

; Magic bootloady number
dw 0xaa55
