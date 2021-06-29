%token NAME INTNUMBER APPROXNUM

%token SELECT
%token FROM
%token ALL
%token DISTINCT
%token TOP
%token PERCENT

%left '+' '-'
%left '*' '/'

%union{
    char* strVal;
    int intVal;
    double floatVal;
}

%type <strVal> NAME
%type <intVal> INTNUMBER expr
%type <floatVal> APPROXNUM

%{
    #include <stdio.h> 
    #include <stdlib.h>

    void yyerror(char*);
    int yylex(void);
%}

%%

/****  top level  ***/
statement_list:
    statement_list statement ';' '\n'
    |
    ;
statement:
    select_statement
    /*|delete_statement*/
    ;

/****  expressions  ****/
expr:
    INTNUMBER           {$$ = $1;printf("interger");}
    |'(' expr ')'       {$$ = $2;printf("()");}
    |expr '+' expr      {$$ = $1 + $3;}
    |expr '-' expr      {$$ = $1 - $3;}
    |expr '*' expr      {$$ = $1 * $3;}
    |expr '/' expr      {$$ = $1 / $3;}
    |
    ;
    
/****  select statement  ****/
select_statement:
    SELECT select_options top_options /*select_expr_list*/  {printf("select no data.\n");}
    ;
select_options:
                                {/*empty*/}
    |select_options ALL         {printf("select options \"all\"\n");}
    |select_options DISTINCT    {printf("select options \"distinct\"\n");}
    ;
top_options:    /* not define "with ties" yet because of the limitaion of this statement */
                                {/*empty*/}
    |top_options TOP expr PERCENT   {printf("select options \"top expr percent\"\n");}
    |top_options TOP expr           {printf("select options \"top expr\"\n%d\n", $3);}
    ;
select_expr_list:
    '*'                                     {printf("select *.\n");}
    |select_expr                            {}
    |select_expr_list ',' select_expr       {}
    ;
select_expr:
    NAME /*option_as_alias*/    {/*empty*/}
    |
    ;
from_statement:
    FROM table
    ; 
table:
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