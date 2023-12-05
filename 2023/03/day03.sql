SELECT * FROM Import.Day03

SELECT DISTINCT LEN(column1) FROM Import.Day03

ALTER TABLE Import.Day03 ADD RowID INT IDENTITY(1,1)

/* Let's parse out the digits and symbols and record where they are in a grid */

DROP TABLE IF EXISTS #numbers
CREATE TABLE #numbers (
    RowNum INT,
    ColumnNum INT,
    Digit INT
)
DROP TABLE IF EXISTS #symbols
CREATE TABLE #symbols (
    RowNum INT,
    ColumnNum INT,
    Symbol CHAR(1)
)

DECLARE @ct AS INT
DECLARE @Row AS INT
DECLARE @char AS CHAR(1)
SET @ct = 1
SET @Row = 1

WHILE @Row <= 140
BEGIN
    WHILE @ct <= 140
    BEGIN
        SELECT @char = SUBSTRING(column1,@ct,1) FROM Import.Day03 WHERE RowID = @Row
        IF @char <> '.'
        BEGIN
            IF @char LIKE '[0-9]'
                INSERT INTO #numbers (RowNum,ColumnNum,Digit) VALUES (@Row,@ct,@char)
            ELSE
                INSERT INTO #symbols (RowNum,ColumnNum,Symbol) VALUES (@Row,@ct,@char)
        END

        SET @ct = @ct + 1
    END
    SET @ct = 1
    SET @Row = @Row + 1
END

SELECT * FROM #numbers
SELECT * FROM #symbols
SELECT * FROM #numbers WHERE RowNum = 1

/* Gaps and Islands problem */
/* 
Group the numbers for each row by consecutive columns 
Then, find the minimium and maximum column for each row group and pull that substring out of the import data
*/

DROP TABLE IF EXISTS #PartsCheck
;WITH cte AS (
    SELECT RowNum, ColumnNum, Digit, ROW_NUMBER() OVER (PARTITION BY RowNum ORDER BY RowNum,ColumnNum) AS RowRow, 
    ColumnNum - ROW_NUMBER() OVER (PARTITION BY RowNum ORDER BY RowNum,ColumnNum) AS RowGroup
    FROM #numbers 
)
SELECT RowNum, RowGroup, MIN(ColumnNum) AS StartPos, MAX(ColumnNum) AS EndPos, 
CAST(SUBSTRING(i.column1,MIN(ColumnNum),MAX(ColumnNum)-MIN(ColumnNum)+1) AS INT) AS PartNumber
INTO #PartsCheck
FROM cte INNER JOIN Import.Day03 i ON cte.RowNum = i.RowID
GROUP BY RowNum, RowGroup, i.column1
ORDER BY RowNum, RowGroup

/* 
Now we know each number and its row, and the starting and ending position.
We can basically draw a "box" around each number (one row up and down and one column left and right)
and check the symbols table to see if any symbols fall within the bounding box
*/

SELECT SUM(PartNumber) 
FROM #PartsCheck p INNER JOIN #symbols s ON 
s.RowNum BETWEEN p.RowNum - 1 AND p.RowNum + 1 
AND s.ColumnNum BETWEEN p.StartPos - 1 AND p.EndPos + 1
--520019


/* Part 2 */

/* Get the gears (*) that that are adjacent to 2 parts */
;WITH cte AS (
    SELECT s.RowNum, s.ColumnNum
    FROM #PartsCheck p INNER JOIN #symbols s ON 
    s.RowNum BETWEEN p.RowNum - 1 AND p.RowNum + 1 
    AND s.ColumnNum BETWEEN p.StartPos - 1 AND p.EndPos + 1
    WHERE s.Symbol = '*'
    GROUP BY s.RowNum, s.ColumnNum
    HAVING COUNT(*) > 1
)
SELECT cte.RowNum, cte.ColumnNum, PartNumber, ROW_NUMBER() OVER (PARTITION BY cte.RowNum, cte.ColumnNum ORDER BY p.RowNum, p.RowGroup) AS GearNumber
INTO #gears
FROM #PartsCheck p INNER JOIN #symbols s ON 
s.RowNum BETWEEN p.RowNum - 1 AND p.RowNum + 1 
AND s.ColumnNum BETWEEN p.StartPos - 1 AND p.EndPos + 1
INNER JOIN cte ON cte.ColumnNum = s.ColumnNum AND cte.RowNum = s.RowNum

SELECT SUM(GearRatio) FROM (
    SELECT g1.PartNumber AS Part1, g2.PartNumber AS Part2, g1.PartNumber * g2.PartNumber AS GearRatio 
    FROM #gears g1 INNER JOIN #gears g2 ON g1.ColumnNum = g2.ColumnNum AND g1.RowNum = g2.RowNum
    WHERE g1.GearNumber = 1 AND g2.GearNumber = 2
) gr
--75519888