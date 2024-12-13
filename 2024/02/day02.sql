SELECT * FROM Import.Day02
order by column1

-- This is a mess, of course. Let's clean it up a bit first.

ALTER TABLE Import.Day02 ADD RowID INT IDENTITY(1,1)

DROP TABLE IF EXISTS #Reports
SELECT RowID, column1 + ' ' + column2 AS Report
INTO #Reports
FROM Import.Day02

DROP TABLE IF EXISTS #Levels
SELECT *
INTO #Levels
FROM #Reports
CROSS APPLY STRING_SPLIT(Report,' ',1)
ORDER BY RowID, ordinal

DROP TABLE IF EXISTS #Analysis
SELECT *, -1 * (TRY_CAST(value AS INT) - TRY_CAST(NextValue AS INT)) AS Delta
INTO #Analysis
FROM (
    SELECT *, LEAD(value,1) OVER (PARTITION BY RowID ORDER BY RowID, ordinal) AS NextValue
    FROM #Levels
) d
WHERE NextValue IS NOT NULL

-- Unsafe because levels are increasing or decreasing too rapidly or are not changing
DELETE FROM #Analysis WHERE RowID IN (
    SELECT RowID 
    FROM #Analysis
    WHERE ABS(Delta) > 3 OR Delta = 0
)

-- Unsafe because values are both increasing and decreasing 
DELETE FROM #Analysis WHERE RowID IN (
    SELECT a.RowID
    FROM #Analysis a INNER JOIN ( -- decreasing values
        SELECT DISTINCT RowID 
        FROM #Analysis
        WHERE Delta < 0
    ) d ON a.RowID = d.RowID
    INNER JOIN ( -- increasing values
        SELECT DISTINCT RowID
        FROM #Analysis
        WHERE Delta > 0
    ) i ON a.RowID = i.RowID
)

SELECT * FROM #Analysis
ORDER BY RowID, ordinal

SELECT COUNT(DISTINCT RowID) FROM #Analysis
--326

-- Part 2

DROP TABLE IF EXISTS #Analysis
SELECT *, -1 * (TRY_CAST(value AS INT) - TRY_CAST(NextValue AS INT)) AS Delta
INTO #Analysis
FROM (
    SELECT *, LEAD(value,1) OVER (PARTITION BY RowID ORDER BY RowID, ordinal) AS NextValue
    FROM #Levels
) d
WHERE NextValue IS NOT NULL

SELECT * FROM #Analysis

ALTER TABLE #Analysis ADD IsUnsafe BIT NOT NULL DEFAULT 0

-- Unsafe because levels are increasing or decreasing too rapidly or are not changing
UPDATE #Analysis SET IsUnsafe = 1 WHERE ABS(Delta) > 3 OR Delta = 0 

DELETE FROM #Analysis WHERE RowID IN (
    SELECT RowID 
    FROM #Analysis
    WHERE IsUnsafe = 1
    group by RowID
    HAVING COUNT(*) > 1
)
--ORDER BY RowID, ordinal

SELECT * FROM #Analysis
ORDER BY RowID, ordinal

-- Unsafe because values are both increasing and decreasing 

-- Get records that already have an unsafe value
DROP TABLE IF EXISTS #UnsafeA
SELECT * 
INTO #UnsafeA
FROM #Analysis
WHERE RowID IN (
    SELECT RowID FROM #Analysis WHERE IsUnsafe = 1
)

-- Remove the unsafe values and then check if there are any more unsafe values. If so, the report is unsafe
DELETE FROM #UnsafeA WHERE IsUnsafe = 1

SELECT * FROM #Levels l INNER JOIN #UnsafeA a ON l.RowID = a.RowID AND l.ordinal = a.ordinal
SELECT * FROM #UnsafeA

DROP TABLE IF EXISTS #UnsafeAnalysis
SELECT *, -1 * (TRY_CAST(value AS INT) - TRY_CAST(NextValue AS INT)) AS Delta
INTO #UnsafeAnalysis
FROM (
    SELECT l.*, LEAD(l.value,1) OVER (PARTITION BY l.RowID ORDER BY l.RowID, l.ordinal) AS NextValue
    FROM #Levels l INNER JOIN #UnsafeA a ON l.RowID = a.RowID AND l.ordinal = a.ordinal
) d
WHERE NextValue IS NOT NULL

SELECT * FROM #UnsafeAnalysis ORDER BY RowID, ordinal

-- Unsafe because levels are increasing or decreasing too rapidly or are not changing
DELETE FROM #UnsafeAnalysis WHERE RowID IN (
    SELECT RowID 
    FROM #UnsafeAnalysis
    WHERE ABS(Delta) > 3 OR Delta = 0
)


DELETE FROM #UnsafeAnalysis WHERE RowID IN (
    SELECT a.RowID
    FROM #UnsafeAnalysis a INNER JOIN ( -- decreasing values
        SELECT DISTINCT RowID 
        FROM #UnsafeAnalysis
        WHERE Delta < 0
    ) d ON a.RowID = d.RowID
    INNER JOIN ( -- increasing values
        SELECT DISTINCT RowID
        FROM #UnsafeAnalysis
        WHERE Delta > 0
    ) i ON a.RowID = i.RowID
)

-- These are known safe
SELECT * FROM #UnsafeAnalysis ORDER BY RowID, ordinal

-- Already checked and we'll add in the safe records at the end
DELETE FROM #Analysis WHERE RowID IN (SELECT RowID FROM #UnsafeA)

SELECT * FROM #Analysis 

-- Also known safe
DROP TABLE IF EXISTS #Safe
SELECT * INTO #Safe FROM #Analysis
WHERE RowID NOT IN (
    SELECT a.RowID
    FROM #Analysis a INNER JOIN ( -- decreasing values
        SELECT DISTINCT RowID 
        FROM #Analysis
        WHERE Delta < 0
    ) d ON a.RowID = d.RowID
    INNER JOIN ( -- increasing values
        SELECT DISTINCT RowID
        FROM #Analysis
        WHERE Delta > 0
    ) i ON a.RowID = i.RowID
)

-- Also checked
DELETE FROM #Analysis WHERE RowID IN (SELECT RowID FROM #Safe)

SELECT COUNT(DISTINCT RowID) FROM #UnsafeAnalysis
SELECT COUNT(DISTINCT RowID) FROM #Safe

-- These have a potential problem with increasing and decreasing values
SELECT COUNT(DISTINCT RowID) FROM #Analysis


SELECT * FROM #Analysis
ORDER BY RowID, ordinal

SELECT MAX(ordinal) FROM #Analysis

SELECT *, -1 * (TRY_CAST(FIRST_VALUE(value) OVER (PARTITION BY RowID ORDER BY RowID, ordinal) AS INT) - 
TRY_CAST(LAST_VALUE(value) OVER (PARTITION BY RowID ORDER BY RowID, ordinal ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS INT)) AS ReportDelta
FROM #Levels
WHERE RowID IN (
    SELECT RowID FROM #Analysis
)
ORDER BY RowID, ordinal

