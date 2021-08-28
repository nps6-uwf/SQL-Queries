-- Author: Nick Sebasco
-- This query allows the user to perform two types of column searches:
-- (1) Table based column search: You want to search for column names in a large table.  
-- Particularly useful if you are connected to a remote server with a poor connection.
-- (2) Column search on entire database, all tables.
-- You can search for columns in a table or the entire database matching the criteria variable.

USE TeeTurtleProdUser_Snapshot  -- Name of actual database replaced with dbname for anonymity.

DECLARE @tableSearch BIT = 1; -- 1 if you wish to perform a table based search, 0 if you want to search the entire database.
DECLARE @columnCriteria VARCHAR(50) = 'v%'; -- For example, columns starting with v.
DECLARE @tableName VARCHAR(50) = 'ProdOrderDetail';

IF @tableSearch=1
BEGIN
    -- Search a specific table for columns meeting criteria.
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @tableName -- Update the table name here.
    AND COLUMN_NAME LIKE @columnCriteria -- Update the criteria here.
END
    -- Search entire  database for columns meeting criteria.
ELSE
BEGIN
    SELECT C.name  AS 'ColumnName', T.name AS 'TableName'
    FROM sys.columns C
    JOIN sys.tables  T ON (C.object_id = T.object_id)
    WHERE C.name LIKE @columnCriteria
    ORDER BY TableName, ColumnName;
END