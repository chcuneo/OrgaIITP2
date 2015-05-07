# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: clean makes tp2

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99

makes:
	make -C ../../src/bmp
	make -C ../../src/tools
	make -C ../../src/filters

%.o: %.c ../../src/runtest.h 
	gcc $(CFLAGS) -c -o $@ $<
	
tp2: ../../src/runtest.o ../../src/tests.o makes
	gcc $(CFLAGS) ../../src/tests.o ../../src/runtest.o ../../src/filters/*.o ../../src/bmp/*.o -o runtest -lm

clean:
	make -C ../../src/bmp clean
	make -C ../../src/tools clean
	make -C ../../src/filters clean
	rm  -f *.o runtestO0