all:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin
	qemu-system-x86_64 -drive format=raw,file=./bin/boot.bin
clean: 
	rm -f ./bin/boot.bin