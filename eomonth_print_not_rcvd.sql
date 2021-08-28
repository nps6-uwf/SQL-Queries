-- Author: Nick Sebasco
-- The production order proccess consists of 3 stages: 1. Issue, 2. Print, 3. Recieved.
-- This query finds all orders at the end of the month that have made it to the print stage, 
-- but have not yet been recieved.

DECLARE @StartDate DATE = '2018-01-01' -- 1. Change date here.

USE dbname_Snapshot -- Name of actual database replaced with dbname for anonymity.

SELECT SUM(A.prodlineqty) AS 'End of Month Print not Recieved'
FROM
(SELECT
	prodstage,
	openseq,
	prodno,
	sc_timecreated AS print_date,
	prodlineqty
FROM prodorderdetail
WHERE prodstage = 'PRINT'
) A
LEFT JOIN 
(SELECT
	prodstage,
	openseq,
	prodno,
	sc_timecreated AS rcvd_date,
	prodlineqty
FROM prodorderdetail
WHERE prodstage = 'RCVD'
) B ON A.prodno = B.prodno AND A.openseq = B.openseq
AND A.print_date <  DATEADD(MONTH, 1, @StartDate) AND (B.rcvd_date > EOMONTH(@StartDate) OR B.rcvd_date IS NULL)