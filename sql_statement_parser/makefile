CC = gcc
OUT = main.out
DEPENDENCY = json-c

all :
	sh build.sh
	$(CC) -c -o obj/main.o main.c
	$(CC) obj/lex.yy.o obj/main.o obj/y.tab.o -o $(OUT) -l$(DEPENDENCY)

clean : 
	rm *.tab.c *.tab.h *.output lex.yy.c $(OUT) obj/lex.yy.o obj/main.o obj/y.tab.o
