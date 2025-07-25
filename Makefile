calc: calc.c ops.o
	gcc -lm -ggdb -o $@ $^

ops.o: ops.asm
	fasm $< $@


test: calc.c ops_test.o
	gcc -lm -ggdb -o $@ $^

ops_test.o: ops_test.c
	gcc -O0 -c -g -o $@ $^

ops_test.s: ops_test.c
	gcc -O0 -S -o $@ $<
ops_test.txt: ops_test.o
	objdump -d -M intel $< > $@


clean:
	rm -f *.o ops_test.txt ops_test.s

.PHONY: clean

