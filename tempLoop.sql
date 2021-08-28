-- Author: Nick Sebasco
-- Date: 08/27/2021
-- This query will count the number of shipments made by month for a particular year.
-- More generally this query shows how you can aggregate data into a #temp table iteratively.
-- Variables: 
-- @sd:  This is the starting date.  The query will start by grabbing all shipmintes from this date until the end of the month
-- then proceed to the next month and grab all shipments for that month.  This process will continue until the variable n is greater
-- than the limit variable.
-- @N: This is a counter variable.  Should not be modified.  Instead alter the limit.
-- @limit: Represents how many months of data to collect.

DROP TABLE IF EXISTS #temp1

GO

USE dbname_Snapshot -- Note dbname to be replaced by the actual database name.  Query from snapshot, not live database.

DECLARE @sd DATE = '2018-01-01 00:00:00.000'
DECLARE @N INT = 0
DECLARE @limit INT = 12

WHILE @N < @limit
BEGIN
    -- Test for the existence of #temp1. 
	IF  (OBJECT_ID('tempdb..#temp1') IS NULL)
    BEGIN
        SELECT @sd AS 'Start Date', COUNT(od.orderno) AS '# Orders' 
		INTO #temp1
		FROM orderdetail od
		LEFT JOIN orderheader oh ON oh.orderno=od.orderno
		LEFT JOIN invoiceorderheader ioh ON ioh.orderno=od.orderno
		LEFT JOIN orderaddressonetime oat ON oat.orderno = oh.orderno

		WHERE oh.ORDERDATE BETWEEN @sd AND EOMONTH(@sd) AND 
		oat.country != 'US' AND
		ioh.shipvia NOT IN  ('FXIE', 'FXIG')	
    END
    -- If #temp1 already exists, use INSERT to update the table with news rows of data.
	ELSE 
	BEGIN
		INSERT INTO #temp1 SELECT @sd AS 'Start Date', COUNT(od.orderno) AS '# Orders' 
		FROM orderdetail od
		LEFT JOIN orderheader oh ON oh.orderno=od.orderno
		LEFT JOIN invoiceorderheader ioh ON ioh.orderno=od.orderno
		LEFT JOIN orderaddressonetime oat ON oat.orderno = oh.orderno

		WHERE oh.ORDERDATE BETWEEN @sd AND EOMONTH(@sd) AND 
		oat.country != 'US' AND
		ioh.shipvia NOT IN  ('FXIE', 'FXIG')
	END
    -- Update variables.
	SET @N = @N + 1
	SET @sd = DATEADD(MONTH, 1, @sd)
END	

-- Select all data from the generated #temp table.
SELECT * FROM #temp1