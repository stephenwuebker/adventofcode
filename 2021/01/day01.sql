-- import data into dbo.aoc_day1

SELECT * FROM dbo.aoc_day1

ALTER TABLE dbo.aoc_day1 ALTER COLUMN Depth INT
ALTER TABLE dbo.aoc_day1 ADD RowID INT IDENTITY(1,1) 

--part 1
SELECT * FROM dbo.aoc_day1 a LEFT JOIN dbo.aoc_day1 b ON a.RowID-1 = b.RowID
WHERE a.Depth > b.Depth



--part 2
-- create sliding windows
SELECT a.Depth+b.Depth+c.Depth AS TotDepth, ROW_NUMBER() OVER (ORDER BY c.RowID) AS RowID
INTO #slide
FROM dbo.aoc_day1 a 
INNER JOIN dbo.aoc_day1 b ON a.RowID-1 = b.RowID
INNER JOIN dbo.aoc_day1 c ON b.RowID-1 = c.RowID

--same logic as previous part
SELECT * FROM #slide a LEFT JOIN #slide b ON a.RowID-1 = b.RowID
WHERE a.TotDepth > b.TotDepth


--cleanup
DROP TABLE IF EXISTS #slide
DROP TABLE IF EXISTS dbo.aoc_day1