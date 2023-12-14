SELECT * FROM Day09

ALTER TABLE Day09 ADD RowID INT IDENTITY(1,1)

SELECT * FROM Day09 WHERE RowID = 8


DROP TABLE IF EXISTS #Data
CREATE TABLE #Data (RowID INT, ColumnID INT, Value BIGINT)

DECLARE @SQL NVARCHAR(MAX)
SET @SQL = ''

SELECT @SQL = COALESCE(@SQL,'') + '
SELECT RowID, ' + CAST(c.Column_ID AS NVARCHAR) + ' AS ColumnID, ' + c.name + ' AS Value FROM Day09
UNION ALL
'
--SELECT *
FROM sys.columns c INNER JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.name = 'Day09' AND c.name <> 'RowID'

SET @SQL = 'INSERT INTO #Data ' + SUBSTRING(@SQL,1,LEN(@SQL) - 10)
--PRINT @SQL 

EXEC sp_executesql @SQL

DROP TABLE IF EXISTS LastValues
CREATE TABLE LastValues (RowID INT, ColumnID INT, Value BIGINT)

DROP PROCEDURE IF EXISTS ReduceRow
DROP TYPE IF EXISTS OASISTableType
CREATE TYPE OASISTableType 
   AS TABLE
      ( RowID INT
      , ColumnID INT
      , Value BIGINT );
GO

CREATE OR ALTER PROCEDURE ReduceRow 
    @Data AS OASISTableType READONLY
AS 
BEGIN
    DECLARE @DistinctRecords INT, @DistinctValue INT
    SET @DistinctRecords = 0
    SET @DistinctValue = 0
    -- Record the last value in the table first
    INSERT INTO LastValues (RowID, ColumnID, [Value]) 
    SELECT RowID, ColumnID, Value FROM @Data WHERE ColumnID = (SELECT MAX(ColumnID) FROM @Data WHERE Value IS NOT NULL)

    DECLARE @Reduced AS OASISTableType
    INSERT INTO @Reduced SELECT RowID, ColumnID, LEAD([Value],1) OVER (ORDER BY ColumnID) - [Value] AS Value FROM @Data 

    SELECT @DistinctRecords = COUNT(DISTINCT Value) FROM @Data
    IF @DistinctRecords = 1
    BEGIN
        SELECT @DistinctValue = (SELECT TOP 1 Value FROM @Data)
        IF @DistinctValue <> 0
            EXEC ReduceRow @Reduced
    END
    ELSE
        EXEC ReduceRow @Reduced
 
END


TRUNCATE TABLE LastValues

DECLARE @Row INT, @MaxRow INT
DECLARE @RowData AS OASISTableType
SET @Row = 1
SELECT @MaxRow = MAX(RowID) FROM #Data

WHILE @Row <= @MaxRow
BEGIN
    INSERT INTO @RowData SELECT * FROM #Data WHERE RowID = @Row
    EXEC ReduceRow @RowData 
    DELETE FROM @RowData

    SET @Row = @Row + 1
END

SELECT * FROM LastValues

SELECT SUM(Value) FROM LastValues
--1884768153


/* PART 2 */
SELECT * FROM #Data WHERE RowID = 8 ORDER BY ColumnID

SELECT RowID, ColumnID, LEAD([Value],1) OVER (ORDER BY ColumnID) - [Value] AS Value FROM #Data WHERE RowID = 1 


DROP TABLE IF EXISTS FirstValues
CREATE TABLE FirstValues (FVID INT IDENTITY(1,1), RowID INT, ColumnID INT, Value BIGINT)
GO

CREATE OR ALTER PROCEDURE ReduceRow 
    @Data AS OASISTableType READONLY
AS 
BEGIN
    DECLARE @DistinctRecords INT, @DistinctValue INT
    SET @DistinctRecords = 0
    SET @DistinctValue = 0
    -- Record the last value in the table first
    INSERT INTO LastValues (RowID, ColumnID, [Value]) 
    SELECT RowID, ColumnID, Value FROM @Data WHERE ColumnID = (SELECT MAX(ColumnID) FROM @Data WHERE Value IS NOT NULL)

    -- Record the first value in the table first
    INSERT INTO FirstValues (RowID, ColumnID, [Value]) 
    SELECT RowID, ColumnID, Value FROM @Data WHERE ColumnID = (SELECT MIN(ColumnID) FROM @Data WHERE Value IS NOT NULL)


    DECLARE @Reduced AS OASISTableType
    INSERT INTO @Reduced SELECT RowID, ColumnID, LEAD([Value],1) OVER (ORDER BY ColumnID) - [Value] AS Value FROM @Data 

    SELECT @DistinctRecords = COUNT(DISTINCT Value) FROM @Data
    IF @DistinctRecords = 1
    BEGIN
        SELECT @DistinctValue = (SELECT TOP 1 Value FROM @Data)
        IF @DistinctValue <> 0
            EXEC ReduceRow @Reduced
    END
    ELSE
        EXEC ReduceRow @Reduced
 
END

TRUNCATE TABLE LastValues
TRUNCATE TABLE FirstValues

DECLARE @Row INT, @MaxRow INT
DECLARE @RowData AS OASISTableType
SET @Row = 1
SELECT @MaxRow = MAX(RowID) FROM #Data

WHILE @Row <= @MaxRow
BEGIN
    INSERT INTO @RowData SELECT * FROM #Data WHERE RowID = @Row
    EXEC ReduceRow @RowData 
    DELETE FROM @RowData

    SET @Row = @Row + 1
END

SELECT * FROM LastValues

SELECT * FROM FirstValues
WHERE RowID = 1

SELECT SUM(IIF(RowNum % 2 = 1, 1, -1) * Value)
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY RowID ORDER BY RowID) AS RowNum
    FROM FirstValues t 
) x