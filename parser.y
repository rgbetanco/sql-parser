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
    SELECT COLUMN FROM TABLE {}
    ;
COLUMN:
    NAME    {printf("column name : %s\n", $1); free($1);}
    |NAME ',' NAME {printf("column anem : %s and %s\n", $1, $3); free($1); free($3);}
    ;
TABLE:
    NAME    {printf("table name : %s\n", $1); free($1);}
    ;

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