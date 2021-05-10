cd asm

# The bootloader will allocate disk space to jump to 16-bit mode
nasm bootloader.asm -f bin -o ../build/bootloader.bin

nasm gdt.asm -f elf64 -o ../build/gdt.o
nasm boot16/boot16.asm -f elf64 -o ../build/boot16.o
nasm boot32/boot32.asm -f elf64 -o ../build/boot32.o
nasm boot64/boot64.asm -f elf64 -o ../build/boot64.o

cd ../src
gcc -fPIC -fcf-protection=none -O0 -fno-stack-protector -z execstack \
	-ffreestanding -mno-red-zone -m64 \
	-c kernel.cpp -o ../build/kernel.o

cd ../build

# The .kep is the kernel entrypoint address that the bootloader loads disk sectors into
# So that code must run before all else, in order
# The GDT can't be far from there because code in .kep references it, so it comes next
# Then, we're free to place text where-ever it happens to fit
ld -o kernel.tmp \
	--section-start=.kep=0x7e00 \
	--section-start=.gdt=0x7f00 \
	--section-start=.text=0x8000 \
	boot16.o boot32.o boot64.o kernel.o gdt.o

objcopy -O binary kernel.tmp kernel.bin

cat bootloader.bin kernel.bin > bootloader-ext.bin
