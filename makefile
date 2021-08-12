CC = g++
OUT = main.out
DEPENDENCY = -ljson-c

all :
	sh sql_statement_parser/build.sh
	$(CC) -c main.cpp -o main.o
	$(CC) sql_statement_parser/obj/lex.yy.o sql_statement_parser/obj/y.tab.o main.o -o $(OUT) $(DEPENDENCY)

clean : 
	cd sql_statement_parser && make clean
	rm main.o $(OUT)