%token SELECT FROM STRING

%union{
    char* strVal;
    int intVal;
}

%type <strVal> STRING name

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
    SELECT select_list from_statement
    ;
select_list:
    '*'
    |name   {printf("select_list : %s\n", $1); free($1);}
    |name ',' name {printf("select_list : %s, %s\n", $1, $3); free($1); free($3);}
    ;
from_statement:
    FROM table
    ; 
table:
    name    {printf("table name : %s\n", $1); free($1);}
    ;
name:
    STRING              {$$ = strdup($1); free($1);}
    |'\'' STRING '\''   {$$ = strdup($2); free($2);}
    |'\"' STRING '\"'   {$$ = strdup($2); free($2);}
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