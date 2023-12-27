USE AdventOfCode2023

--DROP TABLE IF EXISTS Day10
--CREATE TABLE Day10 (RowID INT IDENTITY(1,1), idata varchar(150))

--INSERT INTO Day10
--SELECT * FROM OPENROWSET (BULK N'/Users/swuebker/Workspaces/AdventOfCode/adventofcode/2023/10/input.txt', 
--FORMATFILE = '/Users/swuebker/Workspaces/AdventOfCode/adventofcode/2023/10/format.xml') a

SELECT * FROM Day10

ALTER TABLE Day10 ADD RowID INT IDENTITY(1,1)

DECLARE @ct INT
DECLARE @SQL NVARCHAR(MAX)
SET @ct = 1

WHILE @ct <= 140
BEGIN
    SET @SQL = 'ALTER TABLE Day10 ADD Column' + CAST(@ct AS nvarchar) + ' CHAR(1)'
    EXEC sp_executesql @SQL

    SET @SQL = 'UPDATE Day10 SET Column' + CAST(@ct AS nvarchar) + ' = SUBSTRING(idata,' + CAST(@ct AS nvarchar) + ',1)'
    EXEC sp_executesql @SQL

    SET @ct = @ct + 1
END


-- Find the start
SELECT CHARINDEX('S',idata,1),* FROM Day10 WHERE idata LIKE '%S%'