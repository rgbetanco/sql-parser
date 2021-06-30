%token NAME INTNUMBER APPROXNUM

/* reserved word */
%token SELECT
%token FROM
%token ALL
%token DISTINCT
%token TOP
%token PERCENT
%token AS
%token WITH
%token TIES

%left '+' '-'
%left '*' '/'

%union{
    char* strVal;
    int intVal;
    double floatVal;
}

%type <strVal> NAME expr
%type <intVal> INTNUMBER
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
    INTNUMBER           {printf("expression interger %d\n", $1);}
    |'(' expr ')'       {printf("expression \"(%d)\"\n", $2);}
    |expr '+' expr      {}
    |expr '-' expr      {}
    |expr '*' expr      {}
    |expr '/' expr      {}
    |NAME               {printf("expression name %s\n", $1); free($1);}
    |NAME '.' NAME      {printf("expression field name %s.%s\n", $1, $3); free($1);}
    ;

/****  select statement  ****/
select_statement:
    SELECT select_options top_options select_expr_list  {printf("select no data.\n");}
    ;
select_options:
                                {/*empty*/}
    |select_options ALL         {printf("select options \"all\"\n");}
    |select_options DISTINCT    {printf("select options \"distinct\"\n");}
    ;
top_options:
                                    {/*empty*/}
    |top_options TOP expr PERCENT WITH TIES     {printf("select options \"top expr percent with ties\"\n");}
    |top_options TOP expr PERCENT               {printf("select options \"top expr percent\"\n");}
    |top_options TOP expr WITH TIES             {printf("select options \"top expr with ties\"\n");}
    |top_options TOP expr                       {printf("select options \"top expr\"\n");}
    ;
select_expr_list:
    select_expr                        {/*empty*/}
    |select_expr_list ',' select_expr   {/*empty*/}
    ;
select_expr:    /* funciton not complete yet */
    '*'                 {printf("select \"*\".\n");}
    |expr opt_as_alias
    |NAME '=' expr
    ;
opt_as_alias:
                    {/*empty*/}
    |AS NAME        {printf("as %s\n", $2); free($2);}
    |NAME           {printf("as %s\n", $1); free($1);}

%%

int main(void)
{
    #ifdef YYDEBUG
    yydebug = 0;    //if yydebug = 1, it will show the degug info in command line
    #endif

    yyparse();
    return 0;
}

void yyerror(char* s)
{
    fprintf(stderr, "error %s\n", s);
}