calc: calc.c ops.o
	gcc -lm -ggdb -o $@ $^

ops.o: ops.asm
	fasm $< $@


test: calc.c ops_test.o
	gcc -lm -ggdb -o $@ $^

ops_test.o: ops_test.c
	gcc -c -lm -ggdb $^

