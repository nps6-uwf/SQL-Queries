-- Author: Nick Sebasco 
-- This report will provide activities performed at each Warehouse by month.
-- The loop executes the query for each of our two warehouses.
-- Date change is needed at 1 location [1]

DECLARE @StartDate DATE = '2021-03-01'; -- [1] Change date here.
DECLARE @i INT = 1; -- Counter variable updated with every loop iteration.

USE dbname_Snapshot -- Name of actual database replaced with dbname for anonymity.

WHILE (@i <= 2) -- Execute query 2 times. (Once for each warehouse value)
BEGIN
	DROP TABLE IF EXISTS #temp1
    SELECT IT.INVTRXTYPE, IT.INVTRXDATE, IT.INVTRXQTY, ItemInvCost.CURRENTITEMCOST
    INTO #TEMP1
    FROM InvTransactions IT
    LEFT JOIN ItemInvCost ON ItemInvCost.ITEMNO=IT.ITEMNO
    WHERE INVTRXDATE BETWEEN @StartDate AND EOMONTH(@StartDate)
    AND ((@i = 2 AND TRIM(IT.Warehouse) = 'TT') OR @i = 1)

    SELECT 
    CASE WHEN #TEMP1.INVTRXTYPE='MOVE ' THEN 'MOVE'
        WHEN #TEMP1.INVTRXTYPE='WPULL' THEN 'WAVEPULL'
        WHEN #TEMP1.INVTRXTYPE='SHIP ' THEN 'SHIP'
        WHEN #TEMP1.INVTRXTYPE='RTRN ' THEN 'RETURN'
        WHEN #TEMP1.INVTRXTYPE='RM   ' THEN 'RAW MATERIAL'
        WHEN #TEMP1.INVTRXTYPE='RECV ' THEN 'RECEIVED'
        WHEN #TEMP1.INVTRXTYPE='CNVRT' THEN 'CONVERT'
        WHEN #TEMP1.INVTRXTYPE='ADJ  ' THEN 'ADJUSTMENT'
        WHEN #TEMP1.INVTRXTYPE='CYCL ' THEN 'CYCLE COUNTS'
        WHEN #TEMP1.INVTRXTYPE='TRSFR' THEN 'TRANSFER'
        WHEN #TEMP1.INVTRXTYPE='TRIN ' THEN 'TRACKING IN'
        WHEN #TEMP1.INVTRXTYPE='TROUT' THEN 'TRACKING OUT'
    ELSE #TEMP1.INVTRXTYPE
    END AS INVTRANSACTION, 
    SUM(INVTRXQTY) AS QTYQOH, SUM(INVTRXQTY * CURRENTITEMCOST) AS COST FROM #TEMP1
    LEFT JOIN InvTrxType ON InvTrxType.InvTrxType=#TEMP1.INVTRXTYPE
    GROUP BY #TEMP1.INVTRXTYPE
    ORDER BY INVTRANSACTION ASC

    SET @i = @i + 1;
END

