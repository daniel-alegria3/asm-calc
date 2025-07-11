calc: main.c calc.o
	gcc main.c calc.o -o $@

calc.o: calc.asm
	fasm calc.asm $@

