[section .gdt]

gdt_nulldesc:
	dd 0
	dd 0

global gdt_codedesc
gdt_codedesc:
	dw 0xFFFF 	; Limit 
	dw 0x0000	; Base(low)
	db 0x00		; base(medium)
	db 10011010b; Flags
	db 11001111b; Flags + upper limit
	db 0x00		; Base(high)

global gdt_datadesc
gdt_datadesc:
	dw 0xFFFF 	
	dw 0x0000	
	db 0x00
	db 10010010b
	db 11001111b
	db 0x00

gdt_end:

global gdt_descriptor
gdt_descriptor:
	gtd_size: 
		dw gdt_end - gdt_nulldesc - 1
		dq gdt_nulldesc 

global codeseg
global dataseg

codeseg equ (gdt_codedesc - gdt_nulldesc)
dataseg equ (gdt_datadesc - gdt_nulldesc)
