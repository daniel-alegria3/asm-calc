calc: main.c calc.o
	gcc main.c calc.o -lm -ggdb -o $@

calc.o: calc.asm
	fasm calc.asm $@

