all: dwarfish


es-lang-c-std99.o: es-lang-c-stdc99.c
	gcc -Wall -c -g $< -I.

dwarfish.o: dwarfish.c
	gcc -Wall -c -g $< -I/usr/include/dwarves -I.

dwarfish: dwarfish.o es-lang-c-stdc99.o
	gcc -o $@ $^ -ldwarves