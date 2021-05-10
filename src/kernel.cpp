// We're finally in C now. Praise the lord.

// #define P2V(a) (((void *) (a)) + KERNBASE) ???

#define VGA_MEMORY_START 0xb8000
#define VGA_ADDRESS_SPACE ((unsigned short*)0xb8000)
#define VGA_COLUMN_COUNT 80
#define VGA_ROW_COUNT 25

volatile int __attribute__ ((section (".text"))) i = 0;
volatile char __attribute__ ((section (".text"))) p[] = "Running this from C assholes.";

void ClearScreen()
{
    i = 0;
    for(; i < VGA_COLUMN_COUNT * VGA_ROW_COUNT; i++)
    {
        VGA_ADDRESS_SPACE[i] = 0x0000;
    }
}


void WriteString()
{
    i = 0;
    for (; p[i] != 0; ++i)
    {
        ((unsigned char*)VGA_MEMORY_START)[(i * 2)] = p[i];
        ((unsigned char*)VGA_MEMORY_START)[(i * 2) + 1] = 7;
    }
}

extern "C" void _start()
{
    ClearScreen();
    WriteString();
    return;
}


/*EVGA_CLEAR_SCREEN32:
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
    ret 4*/
