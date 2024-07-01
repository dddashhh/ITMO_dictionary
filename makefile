ASM = nasm
ASMFLAGS = -felf64
LD = ld

lib.o: lib.asm
	$(ASM) $(ASMFLAGS) lib.asm -o lib.o

dict.o: dict.asm lib.inc
	$(ASM) $(ASMFLAGS) dict.asm -o dict.o

main.o: main.asm lib.inc dict.inc words.inc
	$(ASM) $(ASMFLAGS) main.asm -o main.o


main: main.o lib.o dict.o
	$(LD) -o main $^

.PHONY: clean 

clean:
	rm *.o

.PHONY: test
test:
	python3 test.py