all: lexer parser
	g++ y.tab.c lex.yy.c  -o parser

lexer: lexer.l
	flex lexer.l

parser: parse.y
	yacc -dy -v parse.y

clean:
	-rm -f y.tab.h
	-rm -f parse.c
	-rm -f y.tab.c
	-rm -f lex.yy.c
	-rm -f parser

test:
	./parser <../samples/input1
	./parser <../samples/input2
	./parser <../samples/input3
	./parser <../samples/error1
	./parser <../samples/error2
	./parser <../samples/error3
	./parser <../samples/error4
	./parser <../samples/error5
	./parser <../samples/error6
	./parser <../samples/error7
	./parser <../samples/error8
	./parser <../samples/error9
	./parser <../samples/error10


