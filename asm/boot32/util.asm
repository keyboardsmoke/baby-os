BOOTLOADER_EVGA_CLEAR_SCREEN:
    mov eax, 0xbffff ; end of video memory
    mov ecx, 0xb8000 ; start of video memory
ContinueLoop:
    mov [ecx], byte 0 ; memset to 0 basically
    inc ecx
    cmp ecx, eax
    jz EVGAFuncRet
    jmp ContinueLoop
EVGAFuncRet:
    ret

BOOTLOADER_EVGA_PRINT_ERROR:
    push ebp
    mov ebp, esp
    call BOOTLOADER_EVGA_CLEAR_SCREEN
    xor eax, eax ; index into string/video memory buffer
    mov ebx, [ebp+8] ; first parameter
    mov ecx, 0xb8000 ; start of video memory
EVGAPrintLoop:
    mov dl, byte [ebx + eax] ; get string char
    cmp dl, byte 0 ; end of string
    je EVGAPrintFuncRet
    mov byte [ecx + (eax * 2)], dl ; set first byte to char
    mov byte [ecx + (eax * 2) + 1], 0x07 ; second byte is color format, gray on black here
    inc eax ; increment index
    jmp EVGAPrintLoop

EVGAPrintFuncRet:
    pop ebp
    ret 4

BOOTLOADER_GET_EFLAGS:
    pushfd
    pop eax
    ret

BOOTLOADER_SET_EFLAGS:
    push ebp
    mov ebp, esp
    push dword [ebp+8]
    popfd
    pop ebp
    ret 4

BOOTLOADER_CHECK_CPUID:
    call BOOTLOADER_GET_EFLAGS
    mov ecx, eax ; store original EFLAGS in ECX
    xor eax, 1 << 21 ; attempt to modify CPUID bit
    push eax
    call BOOTLOADER_SET_EFLAGS
    call BOOTLOADER_GET_EFLAGS
    mov edx, eax ; store the "new" value of EFLAGS
    cmp ecx, edx ; check if the modification took hold
    jz CPUIDSupported
    mov eax, 1 ; error
    jmp fnret

CPUIDSupported:
    push ecx
    call BOOTLOADER_SET_EFLAGS ; restore the original value
    xor eax, eax

fnret:
    ret

; BOOTLOADER_CHECK_LONGMODE:
;     mov eax, 0x80000001
;     cpuid
;     test edx, 1 << 29
;     jz NoLongMode
;     ret
; NoLongMode:
;     mov eax, 1
;     ret
; 
