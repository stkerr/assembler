cc = gcc -g
CC = g++ -g

all: assembler

assembler: y.tab.o lex.yy.o
	$(CC) -o assembler lex.yy.o y.tab.o -ll -l y

y.tab.o: assem.y
	yacc -d assem.y
	$(CC) -c y.tab.c

lex.yy.o: assem.l
	lex assem.l
	$(cc) -c lex.yy.c

clean:
	rm -f lex.yy.c y.tab.c y.tab.h assembler *.o
