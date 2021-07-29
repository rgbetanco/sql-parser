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
%token ALTER
%token COLUMN
%token ADD
%token DROP
%token MASKED
%token PERSISTED
%token HIDDEN
%token FUNCTION
%token OFF
%token ONLINE
%token NOCHECK
%token PERIOD
%token SYSTEM_TIME
%token IF
%token MOVE
%token TO
%token TRIGGER
%token CHANGE_TRACKING
%token ENABLE
%token TRACK_COLUMNS_UPDATED
%token ANY
%token SOME
%token TRUNCATE
%token PARTITIONS

%error-verbose  /* let error message more user-friendly */

/* Bison will put this section before yystype definition */
%code requires{
    #include "json-c/json.h"
}

%union{
    char* strVal;
    int intVal;
    double floatVal;
    int subtok;
    struct json_object* json;
}

/* operators and precedence levels */
%left OR
%left AND
%nonassoc LIKE IN
%left '!'
%left BETWEEN
%left <subtok> COMPARISON EQUAL /* = <> < > <= >= <=> */
%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left '^'
%nonassoc UMINUS

%type <strVal> NAME STRING expr select_expr from_statement
%type <intVal> INTNUMBER
%type <floatVal> APPROXNUM
%type <json> query_specification select_expr_list subquery opt_from_list opt_from

%{
    #include <stdio.h> 
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>

    void yyerror(char*);
    int yylex(void);
    bool has_blocked_table(struct json_object* json);
    int json_object_array_to_string_array(struct json_object* json, char*** string_array);  // It will return the length of string array
    void free_string_array(char** string_array, int length);
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
    |delete_statement {}
    |update_statement
    |create_statement
    |alter_statement
    |truncate_statement
    ;

/****  expressions  ****/
expr:
    INTNUMBER           {}
    |USERVAR
    |APPROXNUM
    |NAME STRING
    |expr '+' expr      {}
    |expr '-' expr      {}
    |expr '*' expr      {}
    |expr '/' expr      {}
    | '-' expr %prec UMINUS
    |expr COMPARISON expr
    |expr EQUAL expr
    |expr AND expr
    |expr OR expr
    |NAME               {$$ = strdup($1); free($1);}
    |NAME '.' NAME      {}
    |STRING             {}
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
/****  truncate statement  ****/
truncate_statement:
    TRUNCATE TABLE object opt_with_partitions
    ;
opt_with_partitions:
        {}
    |WITH '(' PARTITIONS '(' partition_number_expression_list ')' ')'
    ;
partition_number_expression_list:
    partition_number_expression
    |partition_number_expression_list ',' partition_number_expression
    ;
partition_number_expression:
    INTNUMBER
    |INTNUMBER TO INTNUMBER
    ;

/****  subquery  ****/
subquery:
    expr EQUAL opt_all_some_any '(' query_specification ')'
    {
        struct json_object* json = $5;
        if(has_blocked_table(json)){
            yyerror("there is blocked table in subquery.");
        }

        printf("%s\n", json_object_to_json_string(json));
        json_object_put(json);
    }
    |expr COMPARISON opt_all_some_any '(' query_specification ')'
    {
        struct json_object* json = $5;
        if(has_blocked_table(json)){
            yyerror("there is blocked table in subquery.");
        }

        printf("%s\n", json_object_to_json_string(json));
        json_object_put(json);
    }
    |expr IN '(' query_specification ')'
    {
        struct json_object* json = $4;
        if(has_blocked_table(json)){
            yyerror("there is blocked table in subquery.");
        }

        printf("%s\n", json_object_to_json_string(json));
        json_object_put(json);
    }
    |expr NOT IN '(' query_specification ')'
    {
        struct json_object* json = $5;
        if(has_blocked_table(json)){
            yyerror("there is blocked table in subquery.");
        }

        printf("%s\n", json_object_to_json_string(json));
        json_object_put(json);
    }
    |EXISTS '(' query_specification ')'  
    {
        struct json_object* json = $3;
        //$$ = json_object_new_object();
        if(has_blocked_table(json)){
            yyerror("there is blocked table in subquery.");
        }

        printf("%s\n", json_object_to_json_string(json));
        json_object_put(json);
        //json_object_object_add($$, "subquery", $3);
    }
    |NOT EXISTS '(' query_specification ')'
    {
        struct json_object* json = $4;
        if(has_blocked_table(json)){
            yyerror("there is blocked table in subquery.");
        }

        printf("%s\n", json_object_to_json_string(json));
        json_object_put(json);
    }
    ;
opt_all_some_any:
        {}
    |ALL
    |SOME
    |ANY
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

/****  alter statement  ****/
alter_statement:
    ALTER TABLE object ALTER COLUMN NAME alter_column_options
    |ALTER TABLE object opt_alter_with ADD column_definition_list
    |ALTER TABLE object opt_alter_with ADD column_constraint_list
    |ALTER TABLE object DROP alter_drop_list
    |ALTER TABLE object opt_with_check_nocheck check_or_nocheck CONSTRAINT ALL
    |ALTER TABLE object opt_with_check_nocheck check_or_nocheck CONSTRAINT column_name_list
    |ALTER TABLE object enable_or_disable TRIGGER ALL
    |ALTER TABLE object enable_or_disable TRIGGER column_name_list
    |ALTER TABLE object enable_or_disable CHANGE_TRACKING opt_with_track_columns_updated
    |ALTER TABLE column_constraint
    ;
enable_or_disable:
    ENABLE 
    |DISABLE
    ;
opt_with_track_columns_updated:
        {}
    |WITH '(' TRACK_COLUMNS_UPDATED EQUAL ON ')'
    |WITH '(' TRACK_COLUMNS_UPDATED EQUAL OFF ')'
    ;
opt_with_check_nocheck:
        {}
    |WITH CHECK
    |WITH NOCHECK
    ;
check_or_nocheck:
    CHECK
    |NOCHECK
    ;
alter_drop_list:
    alter_drop
    |alter_drop_list ',' alter_drop 
    ;
alter_drop:
    opt_constraint opt_if_exists NAME opt_alter_drop_with
    |COLUMN opt_if_exists NAME
    |PERIOD FOR SYSTEM_TIME
    ;
opt_alter_drop_with:
        {}
    |WITH '(' drop_clustered_constraint_option_list ')'
    ;
drop_clustered_constraint_option_list:
    drop_clustered_constraint_option
    |drop_clustered_constraint_option_list ',' drop_clustered_constraint_option
    ;
drop_clustered_constraint_option:
    MAXDOP EQUAL expr
    |ONLINE EQUAL ON
    |ONLINE EQUAL OFF
    |MOVE TO expr
    ;
opt_if_exists:
        {}
    |IF EXISTS
alter_column_options:
    expr opt_collate opt_null_or_not opt_sparse 
    |add_or_drop alter_column_add_drop_statement
    |add_or_drop MASKED opt_with_function
    ;
add_or_drop:
    ADD
    |DROP
    ;
alter_column_add_drop_statement:
    ROWGUIDCOL
    |PERSISTED
    |NOT FOR REPLICATION
    |SPARSE
    |HIDDEN
    ;
opt_with_function:
        {}
    |WITH '(' FUNCTION '=' STRING ')'
    ;
opt_alter_with:
        {}
    |WITH '(' ONLINE EQUAL ON ')'
    |WITH '(' ONLINE EQUAL OFF ')'
    |WITH CHECK
    |WITH NOCHECK
    ;

/****  create statement  ****/
create_statement:
    CREATE TABLE object opt_as_alias '(' column_definition_list ')'
    |CREATE TABLE object opt_as_alias '(' column_constraint_list ')'
    ;
column_definition_list:
    column_definition
    |column_definition_list ',' column_definition
    ;
column_definition:
    NAME data_type opt_filestream opt_collate opt_sparse opt_default opt_null_or_not opt_rowguidcol opt_column_constraint_list opt_column_index
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
opt_default:
        {}
    |opt_constraint NAME DEFAULT expr
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
    |column_constraint_list
    ;
column_constraint_list:
    column_constraint 
    |column_constraint_list ',' column_constraint 
    ;
column_constraint:
    opt_constraint NAME primary_key
    |opt_constraint NAME foreign_key
    |opt_constraint NAME check
    ;
opt_constraint:
        {}
    |CONSTRAINT
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
    ;

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
    ;

/****  delete statement  ****/
delete_statement:
    opt_with DELETE top_options FROM object opt_from_list opt_where opt_option
    |opt_with DELETE top_options object opt_from_list opt_where opt_option 
    ;
object:
    NAME '.' NAME '.' NAME '.' NAME
    |NAME '.' NAME '.' NAME
    |NAME '.' NAME
    |NAME   {}
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
    SELECT select_options top_options select_expr_list opt_into opt_from_list opt_where opt_groupby opt_having 
    {
        $$ = json_object_new_object();
        json_object_object_add($$, "select_list", $4);
        json_object_object_add($$, "table_name", $6);
    }
    ;
select_options:
                                {/*empty*/}
    |select_options ALL         {}
    |select_options DISTINCT    {}
    ;
top_options:
                                    {/*empty*/}
    |top_options TOP expr PERCENT WITH TIES    
    |top_options TOP expr PERCENT              
    |top_options TOP expr WITH TIES            
    |top_options TOP '(' expr ')'              
    |top_options TOP expr
    ;
select_expr_list:
    select_expr                         
    {   
        struct json_object * temp;
        $$ = json_object_new_array();

        temp = json_object_new_string($1);
        json_object_array_add($$, temp);
    }
    |select_expr_list ',' select_expr   
    {   
        /* recursive */
        struct json_object * temp;
        $$ = json_object_new_array();

        temp = json_object_new_string($3);
        json_object_array_add($1, temp);
        $$ = $1;
    }
    ;
select_expr:    /* funciton not complete yet */
    '*'                 
    |expr opt_as_alias {$$ = strdup($1); free($1);}
    |NAME '=' expr
    ;
opt_as_alias:
                    {/*empty*/}
    |AS NAME        
    |AS STRING
    |NAME           
    ;
opt_into:
        {}
    |INTO NAME  
    ;

/****  from statement  ****/
opt_from_list:
        {}
    |FROM opt_from  {$$ = $2;}
    ;
opt_from:
    from_statement
    {
        struct json_object * temp;
        $$ = json_object_new_array();

        temp = json_object_new_string($1);
        json_object_array_add($$, temp);
    }
    |opt_from ',' from_statement
    {   
        /* recursive */
        struct json_object * temp;
        $$ = json_object_new_array();

        temp = json_object_new_string($3);
        json_object_array_add($1, temp);
        $$ = $1;
    }
    ;
from_statement:
    NAME opt_as_alias           {$$ = strdup($1); free($1);}
    |NAME '.' NAME opt_as_alias {$$ = strdup($3); free($3);}
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
    |WHERE subquery {}
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
    fprintf(stderr, "error : %s\n", s);
}

bool has_blocked_table(struct json_object* json)
{
    struct json_object* blocked_table;
    char** blocked_table_array;
    char** table_array;
    int file_length;
    int table_length;
    bool result = false;

    // check if the json object has table_list
    if(json_object_object_get(json, "table_name") == NULL){
        return result;
    }

    // read .json file into the json object
    blocked_table = json_object_from_file("./config/blocked_list.json");
    blocked_table = json_object_object_get(blocked_table, "blocked_table_list");
    file_length = json_object_array_to_string_array(blocked_table, &blocked_table_array);
    
    // extract table_name from json parameter
    struct json_object* temp_pointer;
    temp_pointer = json_object_object_get(json, "table_name"); // no need to free memory
    table_length = json_object_array_to_string_array(temp_pointer, &table_array);

    /*
    for(int i = 0; i < file_length; i++){
        printf("%s\n", blocked_table_array[i]);
    }

    for(int i = 0; i < table_length; i++){
        printf("%s\n", table_array[i]);
    }
    */

    for(int i = 0; i < file_length; i++){
        for(int j = 0; j < table_length; j++){
            if(strcmp(blocked_table_array[i], table_array[j]) == 0){
                result = true;
            }
        }
    }

    // free the memory of string array
    free_string_array(blocked_table_array, file_length);
    free_string_array(table_array, table_length);

    // free the memory of json object
    json_object_put(blocked_table);

    return result;
}

int json_object_array_to_string_array(struct json_object* json, char*** string_array)
{
    int table_length;
    char** temp;
    table_length = json_object_array_length(json);

    temp = malloc(table_length * sizeof(char*));
    for(int i = 0; i < table_length; i++){
        int name_length = json_object_get_string_len((json_object_array_get_idx(json, i)));

        temp[i] = malloc((name_length + 1 + 2) * sizeof(char));
        strcpy(temp[i], json_object_to_json_string(json_object_array_get_idx(json, i)));
    }

    *string_array = temp;
    return table_length;
}

void free_string_array(char** string_array, int length)
{
    for(int i = 0; i < length; i++){
        free(string_array[i]);
    } 
    free(string_array);
}