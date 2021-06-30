# C++ sql-parser
## Syntax for SQL Server from [Microsoft website](https://docs.microsoft.com/zh-tw/sql/t-sql/queries/select-transact-sql?view=sql-server-ver15)
```
<SELECT statement> ::=    
    [ WITH { [ XMLNAMESPACES ,] [ <common_table_expression> [,...n] ] } ]  
    <query_expression>   
    [ ORDER BY <order_by_expression> ] 
    [ <FOR Clause>]   
    [ OPTION ( <query_hint> [ ,...n ] ) ]   
<query_expression> ::=   
    { <query_specification> | ( <query_expression> ) }   
    [  { UNION [ ALL ] | EXCEPT | INTERSECT }  
        <query_specification> | ( <query_expression> ) [...n ] ]   
<query_specification> ::=   
SELECT [ ALL | DISTINCT ]   
    [TOP ( expression ) [PERCENT] [ WITH TIES ] ]   
    < select_list >   
    [ INTO new_table ]   
    [ FROM { <table_source> } [ ,...n ] ]   
    [ WHERE <search_condition> ]   
    [ <GROUP BY> ]   
    [ HAVING < search_condition > ]   
```
## Usage
```
git clone https://github.com/rgbetanco/sql-parser.git
make
select name from city;
```
## Successful Statement
```
select name from city;
select * from city;
select name.* from city;
select name, weather, t as traffic from city;
SELECT FirstName, LastName, BaseRate, BaseRate * 40 AS GrossPay FROM DimEmployee;
SELECT OrderDateKey, SUM(SalesAmount) AS TotalSales FROM FactInternetSales;
SELECT TOP 5 PERCENT score INTO new_table FROM table;
select name from table1, table2;
```