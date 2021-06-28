%token SELECT FROM STRING

%union{
    char* strVal;
    int intVal;
}

%type <strVal> STRING

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
    NAME
    ;
TABLE:
    NAME
    ;
NAME:
    STRING    {printf("column name : %s\n", $1); free($1);}
    |STRING ',' STRING {printf("column anem : %s and %s\n", $1, $3); free($1); free($3);}
    |'\'' STRING '\'' {printf("column name : %s\n", $2); free($2);}
    |'\"' STRING '\"' {printf("column name : %s\n", $2); free($2);}
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