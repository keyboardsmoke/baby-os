[bits 32]

EVGA_CLEAR_SCREEN32:
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

EVGA_PRINT_ERROR32:
    push ebp
    mov ebp, esp
    call EVGA_CLEAR_SCREEN32
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

GET_EFLAGS32:
    pushfd
    pop eax
    ret

SET_EFLAGS32:
    push ebp
    mov ebp, esp
    push dword [ebp+8]
    popfd
    pop ebp
    ret 4

BOOTLOADER_CHECK_CPUID:
    ; ebx = original EFLAGS
    ; ecx = new EFLAGS value
    ; edx = read EFLAGS and compare

    call GET_EFLAGS32
    mov ebx, eax ; store original EFLAGS in ebx
    mov ecx, eax
    xor ecx, 1 << 21 ; attempt to modify CPUID bit
    push ecx
    call SET_EFLAGS32
    call GET_EFLAGS32
    mov edx, eax ; store the "new" value of EFLAGS
    cmp ecx, edx ; check if the modification took hold
    jz CPUIDSupported
    mov eax, 1 ; error
    jmp CPUID_fnret

CPUIDSupported:
    push ecx
    call SET_EFLAGS32 ; restore the original value
    xor eax, eax

CPUID_fnret:
    ret

CHECK_LONGMODE32:
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jnz LongModeSupported
    mov eax, 1
    jmp LongMode_fnret
LongModeSupported:
    xor eax, eax
LongMode_fnret:
    ret

PageTableEntry equ 0x1000

SETUP_PAGING32:
    ; CR3: Used when virtual addressing is enabled, hence when the PG bit is set in CR0. 
    ; CR3 enables the processor to translate linear addresses into physical addresses by 
    ; locating the page directory and page tables for the current task. 
    ; Typically, the upper 20 bits of CR3 become the page directory base register (PDBR), 
    ; which stores the physical address of the first page directory entry. 
    ; If the PCIDE bit in CR4 is set, the lowest 12 bits are used for the process-context identifier (PCID)
	mov edi, PageTableEntry
	mov cr3, edi

	mov dword [edi], 0x2003
	add edi, 0x1000
	mov dword [edi], 0x3003
	add edi, 0x1000
	mov dword [edi], 0x4003
	add edi, 0x1000

	mov ebx, 0x00000003
	mov ecx, 512

    .SetEntry:
		mov dword [edi], ebx
		add ebx, 0x1000
		add edi, 8
		loop .SetEntry

    ; CR4: Used in protected mode to control operations such as virtual-8086 support, enabling I/O breakpoints, 
    ; page size extension and machine-check exceptions.
    mov eax, cr4
    or eax, 1 << 5 ; Physical Address Extension
    mov cr4, eax
    ret

; This is causing explosions...
ENABLE_PAGING32:
    mov eax, cr0
    or eax, 1 << 31 ; If 1, enable paging and use the CR3 register, else disable paging.
    mov cr0, eax
    ret

; Extended Feature Enable Register (EFER)
IA32_EFER equ 0xC0000080

ENABLE_LONGMODE32:
    mov ecx, IA32_EFER
    rdmsr
    or eax, 1 << 8 ; LME (Long Mode Enable)
    wrmsr
    ret

NUMBER_TO_STRING32:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov ecx, 2
    mul ecx ; edx = eax * 2
    mov ebx, NumberStringPool
    add ebx, ecx ; NumberStringPool += (num * 2)
    mov eax, ebx ; return value

    pop ebp
    ret 4

NumberStringPool:
    db '0', 0, '1', 0, '2', 0, '3', 0, '4', 0, '5', 0, '6', 0, '7', 0, '8', 0, '9', 0

SetupLongModeGDT:
    mov eax, gdt_codedesc + 6
	mov [eax], byte 10101111b
    mov eax, gdt_datadesc + 6
	mov [eax], byte 10101111b
	ret
