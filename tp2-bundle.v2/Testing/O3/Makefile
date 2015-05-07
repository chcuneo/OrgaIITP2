# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: clean ../../src/filters/C_blur.o ../../src/filters/ASM_blur1.o ../../src/filters/ASM_blur2.o ../../src/filters/C_merge.o ../../src/filters/ASM_merge1.o ../../src/filters/ASM_merge2.o ../../src/filters/C_hsl.o ../../src/filters/ASM_hsl1.o ../../src/filters/ASM_hsl2.o ../../src/filters/filter_toX.o ../../src/filters/aux.o makes tp2

CFLAGS=-Wall -Wextra -pedantic -O3 -ggdb -lm -std=c99
NASMFLAGS=-f elf64 -g -F DWARF

makes:
	make -C ../../src/bmp
	make -C ../../src/tools

%.o: %.c ../../src/runtest.h ../../src/filters/filters.h
	gcc $(CFLAGS) -c -o $@ $<


%.o: %.asm
	nasm $(NASMFLAGS) -o $@ $<

	
tp2: ../../src/runtest.o ../../src/tests.o makes
	gcc $(CFLAGS) ../../src/tests.o ../../src/runtest.o ../../src/filters/*.o ../../src/bmp/*.o -o runtest -lm

clean:
	make -C ../../src/bmp clean
	make -C ../../src/tools clean
	make -C ../../src/filters clean
	rm  -f *.o runtestO0