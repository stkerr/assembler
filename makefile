cc = gcc -g
CC = g++ -g
yacc=bison -g -r all
lex=$(FLEX)

all: assembler

assembler: y.tab.o lex.yy.o 
	$(CC) -o assembler y.tab.o lex.yy.o -ll -l y

assembler.o: assembler.c
	$(cc) -o assembler.o assembler.c

y.tab.o: assem.y
	$(yacc) -o y.tab.c -d assem.y
	$(CC) -c y.tab.c

lex.yy.o: assem.l
	$(lex) --header-file=assem.l.h assem.l
	$(cc) -c lex.yy.c 

clean:
	rm -f lex.yy.c y.tab.c y.tab.h assembler *.o *.tmp *.debug *.acts
