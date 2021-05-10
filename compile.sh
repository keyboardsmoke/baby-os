cd asm
nasm bootloader.asm -f bin -o ../build/bootloader.bin
nasm extended-boot.asm -f elf64 -o ../build/extended-boot.o

cd ../src
gcc -fcf-protection=none -fno-stack-protector -z execstack -ffreestanding -mno-red-zone -m64 -c kernel.cpp -o ../build/kernel.o

cd ../build
ld -o kernel.tmp -Ttext 0x7e00 extended-boot.o kernel.o

#objcopy --only-keep-debug kernel.tmp kernel.sym
#objcopy --strip-debug kernel.tmp
objcopy -O binary kernel.tmp kernel.bin

cat bootloader.bin kernel.bin > bootloader-ext.bin
cd ..
