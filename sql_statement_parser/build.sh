#!/bin/sh

scriptdir="$(dirname "$0")"
cd "$scriptdir"

SCANNER="scanner.l"
PARSER="parser.y"

flex $SCANNER
bison -vdty $PARSER

gcc -c -o obj/lex.yy.o lex.yy.c
gcc -c -o obj/y.tab.o y.tab.c