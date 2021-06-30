CC = gcc
OUT = parser.out
SCANNER = scanner.l
PARSER = parser.y

all :
	flex -d $(SCANNER)
	bison -vdty $(PARSER)
	$(CC) -o $(OUT) lex.yy.c y.tab.c
	./$(OUT)

clean : 
	rm -rf *.tab.c *.tab.h *.output lex.yy.c $(OUT)
