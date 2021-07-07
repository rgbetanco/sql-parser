%token NAME INTNUMBER APPROXNUM STRING

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
%token INTO
%token WHERE
%token LIKE
%token AND
%token OR
%token IN
%token GROUP
%token BY
%token ROLLUP
%token CUBE
%token GROUPING
%token SETS
%token HAVING
%token ON
%token JOIN
%token INNER
%token OUTER
%token RIGHT
%token LEFT
%token FULL
%token REDUCE
%token REPLICATE
%token REDISTRIBUTE
%token CROSS
%token APPLY
%token ORDER
%token ASC
%token DESC
%token UNION
%token INTERSECT
%token EXCEPT
%token IS
%token NOT
%token NULLX
%token LABEL
%token HASH
%token LOOP
%token MERGE
%token FORCE
%token DISABLE
%token EXTERNALPUSHDOWN
%token CONCAT
%token IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX
%token KEEP
%token KEEPFIXED
%token PLAN
%token MAX_GRANT_PERCENT
%token MIN_GRANT_PERCENT
%token MAXDOP
%token MAXRECURSION
%token NO_PERFORMANCE_SPOOL
%token OPTIMIZE
%token FOR 
%token UNKNOWN
%token PARAMETERIZATION 
%token SIMPLE
%token FORCED
%token QUERYTRACEON
%token RECOMPILE
%token ROBUST
%token SCALEOUTEXECUTION
%token EXPAND 
%token VIEWS
%token FAST
%token OPTION
%token EQUAL
%token INSERT
%token DELETE
%token VALUES
%token DEFAULT
%token USERVAR
%token UPDATE
%token SET
%token CURRENT
%token OF
%token GLOBAL
%token EXISTS
%token CREATE
%token TABLE
%token FILESTREAM
%token COLLATE
%token SPARSE
%token REPLICATION
%token ROWGUIDCOL
%token CONSTRAINT
%token PRIMARY
%token UNIQUE
%token KEY
%token CLUSTERED
%token NONCLUSTERED
%token FOREIGN
%token REFERENCES
%token NO
%token ACTION
%token CASCADE
%token CHECK
%token INDEX

%union{
    char* strVal;
    int intVal;
    double floatVal;
    int subtok;
}

/* operators and precedence levels */
%left OR
%left AND
%nonassoc LIKE IN
%left '!'
%left BETWEEN
%left <subtok> COMPARISON EQUAL/* = <> < > <= >= <=> */
%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left '^'

%type <strVal> NAME STRING
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
    |insert_statement
    |delete_statement
    |update_statement
    |create_statement
    ;
create_statement:
    CREATE TABLE object opt_as_alias '(' column_definition_list ')'
    |CREATE TABLE object opt_as_alias '(' column_straint_list ')'
    ;

/****  expressions  ****/
expr:
    INTNUMBER           {printf("expression interger %d\n", $1);}
    |USERVAR
    |APPROXNUM
    |NAME STRING
    |'(' expr ')'       {printf("(expression)");}
    |expr '+' expr      {}
    |expr '-' expr      {}
    |expr '*' expr      {}
    |expr '/' expr      {}
    |expr COMPARISON expr
    |expr EQUAL expr
    |expr AND expr
    |expr OR expr
    |NAME               {printf("expression name %s\n", $1); free($1);}
    |NAME '.' NAME      {printf("expression field name %s.%s\n", $1, $3); free($1);}
    |STRING             {printf("expression string %s\n", $1); free($1);}
    |expr LIKE expr
    |expr NOT LIKE expr
    |expr IN '(' val_list ')'
    |expr NOT IN '(' val_list ')'
    |expr BETWEEN expr AND expr %prec BETWEEN
    |expr NOT BETWEEN expr AND expr %prec BETWEEN
    |expr IS NULLX
    |expr IS NOT NULLX
    |USERVAR EQUAL expr
    ;

/****  function ****/    
expr:
    NAME '(' opt_val_list ')'  {printf("call function\n");}
    ;
opt_val_list:
                {}
    |val_list
    ;
val_list:
    expr
    |'*'
    |expr ',' val_list
    |query_specification
    ;
/****  create statement  ****/
column_definition_list:
    column_definition
    |column_definition_list ',' column_definition
    ;
column_definition:
    NAME data_type opt_filestream opt_collate opt_sparse opt_not_for_replication opt_null_or_not opt_rowguidcol opt_column_constraint_list opt_column_index
    ;
data_type:
    NAME
    |NAME '.' NAME
    |NAME '(' INTNUMBER ')'
    ;
opt_filestream:
        {}
    |FILESTREAM
    ;
opt_collate:
        {}
    |COLLATE NAME
    ;
opt_sparse:
        {}
    |SPARSE
    ;
opt_not_for_replication:
        {}
    |NOT FOR REPLICATION
    ;
opt_null_or_not:
        {}
    |NULLX
    |NOT NULLX
    ;
opt_rowguidcol:
        {}
    |ROWGUIDCOL
    ;
opt_column_constraint_list:
        {}
    |column_straint_list
    ;
column_straint_list:
    column_straint 
    |column_straint_list ',' column_straint 
    ;
column_straint:
    opt_constraint primary_key
    |opt_constraint foreign_key
    |opt_constraint check
    ;
opt_constraint:
        {}
    |CONSTRAINT NAME
    ;
primary_key:
    PRIMARY KEY opt_clustered opt_on
    |UNIQUE opt_clustered opt_on
    ;
opt_clustered:
        {}
    |CLUSTERED 
    |NONCLUSTERED 
    ;
opt_on:
        {}
    |ON NAME '(' NAME ')'
foreign_key:
    FOREIGN KEY opt_column_name_list REFERENCES object opt_column_name_list opt_on_delete opt_on_update opt_not_for_replication
    |REFERENCES object opt_column_name_list opt_on_delete opt_on_update opt_not_for_replication
    ;
opt_on_delete:
    {}
    |ON DELETE NO ACTION
    |ON DELETE CASCADE
    |ON DELETE SET NULLX
    |ON DELETE SET DEFAULT
    ;
opt_on_update:
    {}
    |ON UPDATE NO ACTION
    |ON UPDATE CASCADE
    |ON UPDATE SET NULLX
    |ON UPDATE SET DEFAULT
    ;
check:
    CHECK opt_not_for_replication '(' expr ')'
    ;
opt_column_index:
        {}
    |INDEX NAME opt_clustered

/****  update statement  ****/
update_statement:
    opt_with UPDATE top_options object SET update_set_list opt_from_list opt_where opt_current_of opt_option
    ;
update_set_list:
    update_set
    |update_set_list ',' update_set 
    ;
update_set:
    NAME EQUAL expr
    |NAME EQUAL DEFAULT
    |NAME EQUAL NULLX
    ;
opt_current_of:
        {}
    |CURRENT OF NAME
    |CURRENT OF GLOBAL NAME

/****  delete statement  ****/
delete_statement:
    opt_with DELETE top_options FROM object opt_from_list opt_where opt_option
    |opt_with DELETE top_options object opt_from_list opt_where opt_option
    ;
object:
    NAME '.' NAME '.' NAME '.' NAME
    |NAME '.' NAME '.' NAME
    |NAME '.' NAME
    |NAME
    ;

/****  insert statement  ****/
insert_statement:
    opt_with INSERT top_options INTO object opt_column_name_list insert_options
    |opt_with INSERT top_options object opt_column_name_list insert_options
    ;
insert_options:
    VALUES values_list
    |query_specification opt_orderby
    |DEFAULT VALUES
    ;
values_list:
    '(' values_options_list ')'
    |values_list ',' '(' values_options_list ')'
    ;
values_options_list:
    values_options
    |values_options_list ',' values_options
    ;
values_options:
    DEFAULT
    |NULLX
    |expr
    ;

/****  select statement  ****/
select_statement:
    opt_with query_expression opt_orderby opt_for opt_option opt_into
    ;
opt_for:    /* for statemetn not complete yet */
        {}
    ;
opt_option:
        {}
    |OPTION '(' query_option_list ')'
    ;
query_option_list:
    query_option
    |query_option_list ',' query_option
    ;
query_option:
    LABEL EQUAL STRING
    |query_hint
    ;
query_hint:
    HASH GROUP
    |ORDER GROUP
    |CONCAT UNION
    |HASH UNION
    |MERGE UNION
    |LOOP JOIN
    |MERGE JOIN
    |HASH JOIN
    |EXPAND VIEWS
    |FAST INTNUMBER
    |FORCE ORDER
    |FORCE EXTERNALPUSHDOWN
    |DISABLE EXTERNALPUSHDOWN
    |FORCE SCALEOUTEXECUTION
    |DISABLE SCALEOUTEXECUTION
    |IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX
    |KEEP PLAN
    |KEEPFIXED PLAN
    |MAX_GRANT_PERCENT '=' INTNUMBER
    |MIN_GRANT_PERCENT '=' INTNUMBER
    |MAXDOP INTNUMBER
    |MAXRECURSION INTNUMBER
    |NO_PERFORMANCE_SPOOL
    |OPTIMIZE FOR UNKNOWN
    |PARAMETERIZATION SIMPLE
    |PARAMETERIZATION FORCED
    |QUERYTRACEON INTNUMBER
    |RECOMPILE
    |ROBUST PLAN
    ;
opt_with:
        {}
    |WITH common_table_expression_list AS '(' query_expression ')'
    ;
common_table_expression_list:
    common_table_expression
    |common_table_expression_list common_table_expression
    ;
common_table_expression:
    NAME opt_column_name_list
    ;
opt_column_name_list:
        {}
    |'(' column_name_list ')'
    ;
column_name_list:
    NAME
    |column_name_list ',' NAME
    ;
query_expression:
    query_specification opt_query
    |'(' query_expression ')' opt_query
    ;
opt_query:
        {}
    |union_list
    ;
union_list:
    union_statement
    |union_list union_statement
    ;
union_statement:
    opt_union query_specification
    |opt_union '(' query_expression ')'
    ;
opt_union:
    UNION
    |UNION ALL
    |EXCEPT
    |INTERSECT
    ;
query_specification:
    SELECT select_options top_options select_expr_list opt_into opt_from_list opt_where opt_groupby opt_having {printf("select\n");}
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
    select_expr                         {/*empty*/}
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
    |AS STRING
    |NAME           {printf("as %s\n", $1); free($1);}
    ;
opt_into:
        {}
    |INTO NAME  {printf("into option\n");}
    ;

/****  from statement  ****/
opt_from_list:
        {}
    |FROM opt_from
    ;
opt_from:
    from_statement
    |opt_from ',' from_statement
    ;
from_statement:
    NAME opt_as_alias
    |NAME '.' NAME opt_as_alias
    |joined_table
    ;
joined_table:
    from_statement join_type from_statement ON expr
    |from_statement CROSS JOIN from_statement
    |NAME cross_outer APPLY NAME
    |'(' joined_table ')'
    ;
join_type:
    opt_join_type opt_join_hint JOIN
    ;
opt_join_type:
        {}
    |INNER
    |LEFT opt_outer
    |RIGHT opt_outer
    |FULL opt_outer
    ;
opt_outer:
        {}
    |OUTER
    ;
opt_join_hint:
        {}
    |REDUCE
    |REPLICATE
    |REDISTRIBUTE
    ;
cross_outer:
    CROSS
    |OUTER
    ;

/****  where statement  ****/
opt_where:
        {}
    |WHERE expr
    |WHERE EXISTS '(' query_expression ')'
    |WHERE NOT EXISTS '(' query_expression ')'
    ;

/****  group by statement  ****/
opt_groupby:
        {}
    |GROUP BY groupby_list
    ;
groupby_list:
    groupby_statement
    |groupby_list ',' groupby_statement
    ;
groupby_statement:
    expr
    |ROLLUP '(' groupby_expr_list ')'
    |CUBE '(' groupby_expr_list ')'
    |GROUPING SETS '(' grouping_set ')'
    |'(' ')'
    ;
groupby_expr_list:
    groupby_expr
    |groupby_expr_list ',' groupby_expr
    ;
groupby_expr:
    expr
    |'(' groupby_expr ',' expr ')'
    ;
grouping_set:
    '(' ')'
    |grouping_set_item_list
    ;
grouping_set_item_list:
    grouping_set_item
    |grouping_set_item_list ',' grouping_set_item
    ;
grouping_set_item:
    groupby_expr
    |ROLLUP '(' groupby_expr_list ')'
    |CUBE '(' groupby_expr_list ')'
    ;

/****  having statement  ****/
opt_having:
        {}
    |HAVING expr
    ;

/****  order by statement  ****/
opt_orderby:
        {}
    |ORDER BY orderby_statement_list
    ;
orderby_statement_list:
    orderby_statement
    |orderby_statement_list ',' orderby_statement
    ;
orderby_statement:
    expr opt_asc_desc
    ;
opt_asc_desc:
        {}
    |ASC
    |DESC
    ;
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