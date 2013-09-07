CFLAGS=-g
LDFLAGS=-O0

a.out: target.o
	gcc $(LDFLAGS) target.o
