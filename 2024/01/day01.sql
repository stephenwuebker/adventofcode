-- CREATE DATABASE AdventOfCode2024

USE AdventOfCode2024

--CREATE SCHEMA Import

SELECT * FROM Import.Day01

-- Create two tables we can sort and join
DROP TABLE IF EXISTS #List1

SELECT ROW_NUMBER() OVER (ORDER BY column1) AS RowID, column1 AS List1
INTO #List1
FROM Import.Day01

DROP TABLE IF EXISTS #List2

SELECT ROW_NUMBER() OVER (ORDER BY column2) AS RowID, column2 AS List2
INTO #List2
FROM Import.Day01


-- Get the differences
SELECT SUM(ABS(l1.List1 - l2.List2)) AS Diff
FROM #List1 l1 INNER JOIN #List2 l2 ON l1.RowID = l2.RowID


-- PART 2
SELECT SUM(SimScore) 
FROM (
    SELECT l1.RowID, l1.List1, COUNT(l2.List2) AS Occurance, l1.List1 * COUNT(l2.List2) AS SimScore
    FROM #List1 l1 LEFT JOIN #List2 l2 ON l1.List1 = l2.List2
    GROUP BY l1.RowID, l1.List1
) d
