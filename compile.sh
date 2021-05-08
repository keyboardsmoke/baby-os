cd asm
nasm bootloader.asm -f bin -o ../build/bootloader.bin
nasm extended-boot.asm -f bin -o ../build/extended-boot.bin
cat ../build/bootloader.bin ../build/extended-boot.bin > ../build/bootloader-ext.bin
cd ..
