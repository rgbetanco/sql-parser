%token SELECT FROM NAME

%union{
    char* strVal;
    int intVal;
}

%type <strVal> NAME

%{
    #include <stdio.h> 
    #include <stdlib.h>

    void yyerror(char*);
    int yylex(void);
%}

%%

statement_list:
    statement_list statement ';' '\n'
    |
    ;
statement:
    SELECT NAME FROM NAME {printf("%s %s\n", $2, $4);}
    ;
/*COLUMN:
    NAME    {printf("column name : %s", $1);}
    ;
TABLE:
    NAME
    ;*/

%%

int main(void)
{
    yyparse();
    return 0;
}

void yyerror(char* s)
{
    fprintf(stderr, "error %s\n", s);
}