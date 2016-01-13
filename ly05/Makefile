all:
	lex ch05.lex
	yacc -d ch05.y
	gcc -c lex.yy.c y.tab.c
	gcc -o hello lex.yy.o y.tab.o -ll

clean:
	rm lex.yy.o y.tab.o lex.yy.c y.tab.c y.tab.h hello
