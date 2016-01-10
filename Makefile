CC = gcc
CFLAGS = -Wall
PRU_ASM = pasm
DTC = dtc

all: 1Gclock.bin 1Gclock

1Gclock.bin: 1Gclock.p
	@echo "\n>> 1Gclock Generating PRU binary"
	$(PRU_ASM) -V3 -b 1Gclock.p

1Gclock: 1Gclock.c
	@echo "\n>> Compiling 1Gclock example"
	$(CC) $(CFLAGS) -c -o 1Gclock.o 1Gclock.c
	$(CC) -lpthread -lprussdrv -o 1Gclock 1Gclock.o

clean:
	rm -rf 1Gclock 1Gclock.bin 1Gclock.o 1Gclock

