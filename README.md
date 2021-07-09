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
### Select statement
```
// basic statement
select name from city;
select * from city;
select name.* from city;
select name from table1, table2;

// 'as' statement
select name, weather, t as traffic from city;
SELECT FirstName, LastName, BaseRate, BaseRate * 40 AS GrossPay FROM DimEmployee;
SELECT OrderDateKey, SUM(SalesAmount) AS TotalSales FROM FactInternetSales;

// 'top' statement
SELECT TOP 5 PERCENT score INTO new_table FROM table;

// 'where' statement
select name from table where id <= 4;
SELECT EmployeeKey, LastName FROM DimEmployee WHERE LastName LIKE ('%Smi%');  
SELECT EmployeeKey, LastName FROM DimEmployee WHERE EmployeeKey <= 500 AND LastName LIKE '%Smi%' AND FirstName LIKE '%A%';
SELECT EmployeeKey, LastName FROM DimEmployee WHERE LastName IN ('Smith', 'Godfrey', 'Johnson');  
SELECT EmployeeKey, LastName FROM DimEmployee WHERE EmployeeKey Between 100 AND 200;

// 'group by' statement
SELECT ColumnA, ColumnB FROM T GROUP BY ColumnA, ColumnB;
SELECT Country, Region, SUM(Sales) AS TotalSales FROM Sales GROUP BY ROLLUP (Country, Region);
SELECT Country, Region, SUM(Sales) AS TotalSales FROM Sales GROUP BY GROUPING SETS ( ROLLUP (Country, Region), CUBE (Country, Region) );
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal FROM Sales.SalesOrderDetail GROUP BY SalesOrderID HAVING SUM(LineTotal) > 100000.00 ORDER BY SalesOrderID ;

// 'order by' statement
SELECT name, SCHEMA_NAME(schema_id) AS SchemaName FROM sys.objects WHERE type = 'U' ORDER BY SchemaName; 
SELECT BusinessEntityID, JobTitle, HireDate FROM HumanResources.Employee ORDER BY DATEPART(year, HireDate);
SELECT LastName, FirstName FROM Person.Person WHERE LastName LIKE 'R%' ORDER BY FirstName ASC, LastName DESC ;  

// joined table statement
SELECT p.ProductID, v.BusinessEntityID FROM Production.Product AS p LEFT JOIN Purchasing.ProductVendor AS v ON (p.ProductID = v.ProductID);

// 'union' statement
SELECT LastName, FirstName,JobTitle FROM dbo.EmployeeOne UNION ALL  
( SELECT LastName, FirstName, JobTitle FROM dbo.EmployeeTwo UNION 
SELECT LastName, FirstName,JobTitle FROM dbo.EmployeeThree);  

// 'with ... as ...' statement
WITH Sales_CTE (SalesPersonID, NumberOfOrders)  
AS  
(  
    SELECT SalesPersonID, COUNT(*)  
    FROM Sales.SalesOrderHeader  
    WHERE SalesPersonID IS NOT NULL  
    GROUP BY SalesPersonID  
)  
SELECT AVG(NumberOfOrders) AS "Average Sales Per Person"  
FROM Sales_CTE; 

// 'option' statement
SELECT ProductID, OrderQty, SUM(LineTotal) AS Total FROM Sales.SalesOrderDetail WHERE UnitPrice < 5.00 GROUP BY ProductID, OrderQty ORDER BY ProductID, OrderQty OPTION (HASH GROUP, FAST 10);
SELECT * FROM FactResellerSales OPTION ( LABEL = 'q17' );  
```
### Delete statement
```
DELETE FROM Sales.SalesPersonQuotaHistory;  
DELETE Production.ProductCostHistory WHERE StandardCost BETWEEN 12.00 AND 14.00 AND EndDate IS NULL;  
DELETE FROM Sales.SalesPersonQuotaHistory WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.SalesPerson WHERE SalesYTD > 2500000.00);
DELETE spqh FROM Sales.SalesPersonQuotaHistory AS spqh INNER JOIN Sales.SalesPerson AS sp ON spqh.BusinessEntityID = sp.BusinessEntityID WHERE sp.SalesYTD > 2500000;
```
### Insert statement
```
INSERT INTO Production.UnitMeasure VALUES (N'FT', N'Feet', '20080414');
INSERT INTO Production.UnitMeasure VALUES (N'FT2', N'Square Feet ', '20080923'),(N'Y', N'Yards', '20080923'), (N'Y3', N'Cubic Yards', '20080923');
INSERT TOP(5)INTO dbo.EmployeeSales  
    OUTPUT inserted.EmployeeID, inserted.FirstName, 
        inserted.LastName, inserted.YearlySales  
    SELECT sp.BusinessEntityID, c.LastName, c.FirstName, sp.SalesYTD   
    FROM Sales.SalesPerson AS sp  
    INNER JOIN Person.Person AS c  
        ON sp.BusinessEntityID = c.BusinessEntityID  
    WHERE sp.SalesYTD > 250000.00  
    ORDER BY sp.SalesYTD DESC;   
```
### Update statement
```
UPDATE Person.Address SET ModifiedDate = GETDATE();
UPDATE Sales.SalesPerson SET Bonus = 6000, CommissionPct = .10, SalesQuota = NULL;  
UPDATE Production.Product SET Color = N'Metallic Red' WHERE Name LIKE N'Road-250%' AND Color = N'Red';
UPDATE TOP (10) HumanResources.Employee SET VacationHours = VacationHours * 1.25;

// using with and update statement
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS  
(  
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,  
        b.EndDate, 0 AS ComponentLevel  
    FROM Production.BillOfMaterials AS b  
    WHERE b.ProductAssemblyID = 800  
          AND b.EndDate IS NULL  
    UNION ALL  
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,  
        bom.EndDate, ComponentLevel + 1  
    FROM Production.BillOfMaterials AS bom   
        INNER JOIN Parts AS p  
        ON bom.ProductAssemblyID = p.ComponentID  
        AND bom.EndDate IS NULL  
)  
UPDATE Production.BillOfMaterials  
SET PerAssemblyQty = c.PerAssemblyQty * 2  
FROM Production.BillOfMaterials AS c  
JOIN Parts AS d ON c.ProductAssemblyID = d.AssemblyID  
WHERE d.ComponentLevel = 0;  
```
### Create statement
```
// basic statement
CREATE TABLE dbo.Employee (EmployeeID INT PRIMARY KEY CLUSTERED);

// foreign key constraint
CREATE TABLE dbo.Employee (
    SalesPersonID INT NULL REFERENCES SalesPerson(SalesPersonID)
);
CREATE TABLE dbo.Employee (
    FOREIGN KEY (SalesPersonID) REFERENCES SalesPerson(SalesPersonID)
);
create table tablename (
    CONSTRAINT FK_SpecialOfferProduct_SalesOrderDetail
    FOREIGN KEY (ProductID, SpecialOfferID)
    REFERENCES SpecialOfferProduct (ProductID, SpecialOfferID)
);

// unique constraint
create table tablename (
    Name NVARCHAR(100) NOT NULL
    UNIQUE NONCLUSTERED
);

// DEFAULT definition
create table tablename (
    name varchar(50) DEFAULT 'New Position - title not formalized yet',
    data datetime DEFAULT (GETDATE())
);

// check constraint
create table tablename (
    number int CHECK (CreditRating >= 1 and CreditRating <= 5)
);
```
### Alter statement
```
// add statement
ALTER TABLE dbo.doc_exa ADD column_b VARCHAR(20) NULL ;
ALTER TABLE dbo.doc_exc ADD column_b VARCHAR(20) NULL CONSTRAINT exb_unique UNIQUE ;
ALTER TABLE dbo.doc_exd WITH NOCHECK ADD CONSTRAINT exd_check CHECK (column_a > 1) ;
ALTER TABLE T2 ALTER COLUMN C2 ADD SPARSE ;

// drop statement
ALTER TABLE dbo.doc_exb DROP COLUMN column_c, column_d;
ALTER TABLE Production.TransactionHistoryArchive DROP CONSTRAINT PK_TransactionHistoryArchive_TransactionID WITH (ONLINE = ON) ;
ALTER TABLE dbo.doc_exc DROP my_constraint ;
ALTER TABLE dbo.doc_exc DROP CONSTRAINT my_constraint, my_pk_constraint, COLUMN column_b;

// alter column statement
ALTER TABLE dbo.doc_exy ALTER COLUMN column_a DECIMAL (5, 2) ;
ALTER COLUMN C2 varchar(50) COLLATE Latin1_General_BIN ;

// others statement
ALTER TABLE dbo.cnst_example NOCHECK CONSTRAINT salary_cap;
ALTER TABLE dbo.trig_example ENABLE TRIGGER trig1;
```