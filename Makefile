# Autor: Bruno Müller Junior
# Data: 08/2007
# Editado por Gabriel Nascarella Hishida do Nascimento
$DEBUG=1

compiler: lex.yy.c compiler.tab.c compiler.o compiler.h
	gcc -g lex.yy.c compiler.tab.c compiler.o -o compiler -ll -ly -lc

lex.yy.c: compiler.l compiler.h
	flex compiler.l

compiler.tab.c: compiler.y compiler.h
	bison compiler.y -d -v -Wall

compiler.o : compiler.h compiler_f.c
	gcc -c compiler_f.c  -o compiler.o 

clean :
	rm -f compiler.tab.* lex.yy.c compiler.o compiler
