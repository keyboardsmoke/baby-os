; The area directly after the bootloader utilized area
POSTBOOT_AREA equ 0x7e00

; This is the number of sectors the bootloader will be able to access after the bootloader reserved space
LOAD_SECTORS equ 4

BOOTLOADER_READ_SECTORS:
    ; [INT 13h AH=02h: Read Sectors From Drive]
    ; Parameters:
    ; AH	02h
    ; AL	Sectors To Read Count
    ; CH	Cylinder
    ; CL	Sector
    ; DH	Head
    ; DL	Drive
    ; ES:BX	Buffer Address Pointer
    ; Result
    ; CF	Set On Error, Clear If No Error
    ; AH	Return Code
    ; AL	Actual Sectors Read Count

    mov ah, 0x02 ; Reserved
    mov al, LOAD_SECTORS ; Sectors To Read Count
    mov ch, 0x00 ; Cylinder
    mov cl, 0x02 ; Sector
    mov dh, 0x00 ; Head
    mov dl, [BOOT_DISK] ; Drive
    mov bx, POSTBOOT_AREA ; Buffer Address Pointer
    int 0x13
    ret

BOOT_DISK:
    db 0
