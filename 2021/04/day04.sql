-- Import data
-- Import boards and the draw
DROP TABLE IF EXISTS dbo.aoc_day4_draw
CREATE TABLE dbo.aoc_day4_draw (
    Value INT,
    DrawNumber INT IDENTITY(1,1)
)
INSERT INTO dbo.aoc_day4_draw (Value)
SELECT value FROM (
SELECT * FROM dbo.aoc_day4_Input_Draw CROSS APPLY string_split(draw,',')
) a

SELECT * FROM dbo.aoc_day4_draw


SELECT * FROM dbo.aoc_day4_Input_Boards
ALTER TABLE dbo.aoc_day4_Input_Boards ADD BoardID INT
ALTER TABLE dbo.aoc_day4_Input_Boards ADD RowID INT IDENTITY(1,1)
ALTER TABLE dbo.aoc_day4_Input_Boards ALTER COLUMN B VARCHAR(5)
ALTER TABLE dbo.aoc_day4_Input_Boards ALTER COLUMN I VARCHAR(5)
ALTER TABLE dbo.aoc_day4_Input_Boards ALTER COLUMN N VARCHAR(5)
ALTER TABLE dbo.aoc_day4_Input_Boards ALTER COLUMN G VARCHAR(5)
ALTER TABLE dbo.aoc_day4_Input_Boards ALTER COLUMN O VARCHAR(5)

SELECT *, CASE WHEN RowID % 5 <> 0 THEN ((RowID % 5 - RowID) / -5) + 1 ELSE ((RowID % 5 - RowID) / -5) END
FROM dbo.aoc_day4_Input_Boards

UPDATE dbo.aoc_day4_Input_Boards SET BoardID = CASE WHEN RowID % 5 <> 0 THEN ((RowID % 5 - RowID) / -5) + 1 ELSE ((RowID % 5 - RowID) / -5) END

SELECT COUNT(*) FROM #draw


DECLARE @DrawNum INT
SET @DrawNum = 1
DECLARE @Draws VARCHAR(300)
SET @Draws = ''
DECLARE @DrawVal VARCHAR(5)
DECLARE @WinRow INT
SET @WinRow = 0
DECLARE @WinCol INT
SET @WinCol = 0
DECLARE @SQL NVARCHAR(MAX)
DECLARE @ParmDef NVARCHAR(500)

WHILE @DrawNum <= 100
BEGIN
    SELECT @DrawVal = CAST(Value AS VARCHAR) FROM #draw WHERE DrawNumber = @DrawNum
    SET @Draws = @Draws + CASE WHEN @Draws = '' THEN '' ELSE ',' END + @DrawVal

    SET @SQL = 'SELECT @WinRowOUT=BoardID FROM dbo.aoc_day4_Input_Boards WHERE 
                B IN (' + @Draws + ') AND
                I in (' + @Draws + ') AND
                N in (' + @Draws + ') AND
                G in (' + @Draws + ') AND
                O in (' + @Draws + ')'
    SET @ParmDef = '@WinRowOUT INT OUTPUT'
    EXEC sp_executesql @SQL, @ParmDef, @WinRowOUT=@WinRow OUTPUT

    IF @WinRow > 1
    BEGIN
        SET @DrawNum = 101
    END

    
    SET @SQL = 'SELECT @WinColOUT = BoardID FROM dbo.aoc_day4_Input_Boards WHERE 
                    B IN (' + @Draws + ') OR
                    I in (' + @Draws + ') OR
                    N in (' + @Draws + ') OR
                    G in (' + @Draws + ') OR
                    O in (' + @Draws + ')
                    GROUP BY BoardID HAVING COUNT(*) = 5'
    SET @ParmDef = '@WinColOUT INT OUTPUT'
    EXEC sp_executesql @SQL, @ParmDef, @WinColOUT=@WinCol OUTPUT

    IF @WinCol > 1
    BEGIN 
        SET @DrawNum = 101
    END

    SET @DrawNum = @DrawNum + 1
END

SELECT @Draws
SELECT @WinCol, @WinRow, @DrawVal

;WITH cte AS (SELECT value FROM string_split(@Draws,','))

SELECT SUM(ColSum)*CAST(@DrawVal AS INT) FROM (
    SELECT SUM(CAST(B AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards 
    WHERE B NOT IN (SELECT value FROM cte) AND
    BoardID IN (@WinCol,@WinRow)
    UNION ALL
    SELECT SUM(CAST(I AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards 
    WHERE I NOT IN (SELECT value FROM cte) AND
    BoardID IN (@WinCol,@WinRow)
    UNION ALL
    SELECT SUM(CAST(N AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards 
    WHERE N NOT IN (SELECT value FROM cte) AND
    BoardID IN (@WinCol,@WinRow)
    UNION ALL
    SELECT SUM(CAST(G AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards 
    WHERE G NOT IN (SELECT value FROM cte) AND
    BoardID IN (@WinCol,@WinRow)
    UNION ALL
    SELECT SUM(CAST(O AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards 
    WHERE O NOT IN (SELECT value FROM cte) AND
    BoardID IN (@WinCol,@WinRow)
) data


-- check answer
--62,55,98,93,48,28,82,78,19,96,31,42,76,25,34,4,18,80,66,6,14
select * from dbo.aoc_day4_Input_Boards where boardid = 21


GO
-- part 2: let the wookie win

DECLARE @WinBoards VARCHAR(300)
SET @WinBoards = '0'
DECLARE @DrawNum INT
SET @DrawNum = 1
DECLARE @Draws VARCHAR(300)
SET @Draws = ''
DECLARE @DrawVal VARCHAR(5)
DECLARE @WinRow INT
SET @WinRow = 0
DECLARE @WinCol INT
SET @WinCol = 0
DECLARE @SQL NVARCHAR(MAX)
DECLARE @ParmDef NVARCHAR(500)

WHILE @DrawNum <= 100
BEGIN
    SELECT @DrawVal = CAST(Value AS VARCHAR)
    FROM dbo.aoc_day4_draw
    WHERE DrawNumber = @DrawNum
    SET @Draws = @Draws + CASE WHEN @Draws = '' THEN '' ELSE ',' END + @DrawVal

    SET @SQL = 'SELECT @WinRowOUT=BoardID FROM dbo.aoc_day4_Input_Boards WHERE 
                B IN (' + @Draws + ') AND
                I in (' + @Draws + ') AND
                N in (' + @Draws + ') AND
                G in (' + @Draws + ') AND
                O in (' + @Draws + ') AND BoardID NOT IN (' + @WinBoards +')'
    SET @ParmDef = '@WinRowOUT INT OUTPUT'
    EXEC sp_executesql @SQL, @ParmDef, @WinRowOUT = @WinRow OUTPUT

    IF @WinRow > 1
    BEGIN
        SET @WinBoards = @WinBoards + ',' + CAST(@WinRow AS VARCHAR)
        SET @WinRow = 0
    END


    SET @SQL = 'SELECT @WinColOUT = BoardID FROM dbo.aoc_day4_Input_Boards WHERE ( 
                    B IN (' + @Draws + ') OR
                    I in (' + @Draws + ') OR
                    N in (' + @Draws + ') OR
                    G in (' + @Draws + ') OR
                    O in (' + @Draws + ') ) AND BoardID NOT IN (' + @WinBoards + ')
                    GROUP BY BoardID HAVING COUNT(*) = 5'
    SET @ParmDef = '@WinColOUT INT OUTPUT'
    EXEC sp_executesql @SQL, @ParmDef, @WinColOUT = @WinCol OUTPUT

    IF @WinCol > 1
    BEGIN
        SET @WinBoards = @WinBoards + ',' + CAST(@WinCol AS VARCHAR)
        SET @WinCol = 0
    END

    SET @DrawNum = @DrawNum + 1
END

SELECT @DrawNum,
       @WinBoards
       -- 2 is the last winner

SET @DrawNum = 1
SET @Draws = ''
SET @DrawVal = ''
SET @WinCol = 0
SET @WinRow = 0

DROP TABLE IF EXISTS #LastWinner
SELECT * INTO #LastWinner FROM dbo.aoc_day4_Input_Boards WHERE BoardID = 2

WHILE @DrawNum <= 100
BEGIN
    SELECT @DrawVal = CAST(Value AS VARCHAR) FROM dbo.aoc_day4_draw WHERE DrawNumber = @DrawNum
    SET @Draws = @Draws + CASE WHEN @Draws = '' THEN '' ELSE ',' END + @DrawVal

    SET @SQL = 'SELECT @WinRowOUT = BoardID FROM #LastWinner WHERE 
                B IN (' + @Draws + ') AND
                I in (' + @Draws + ') AND
                N in (' + @Draws + ') AND
                G in (' + @Draws + ') AND
                O in (' + @Draws + ')'
    SET @ParmDef = '@WinRowOUT INT OUTPUT'
    EXEC sp_executesql @SQL, @ParmDef, @WinRowOUT = @WinRow OUTPUT

    IF @WinRow > 1
    BEGIN
        SET @DrawNum = @DrawNum + 99
    END


    SET @SQL = 'SELECT @WinColOUT = BoardID FROM #LastWinner WHERE  
                    B IN (' + @Draws + ') OR
                    I in (' + @Draws + ') OR
                    N in (' + @Draws + ') OR
                    G in (' + @Draws + ') OR
                    O in (' + @Draws + ') 
                    GROUP BY BoardID HAVING COUNT(*) = 5'
    SET @ParmDef = '@WinColOUT INT OUTPUT'
    EXEC sp_executesql @SQL, @ParmDef, @WinColOUT = @WinCol OUTPUT

    IF @WinCol > 1
    BEGIN
        SET @DrawNum = @DrawNum + 99
    END

    SET @DrawNum = @DrawNum + 1
END

SELECT @Draws
SELECT @DrawNum,@WinCol, @WinRow, @DrawVal


;WITH cte
AS (SELECT value
    FROM STRING_SPLIT(@Draws, ','))
SELECT SUM(ColSum) * CAST(@DrawVal AS INT)
FROM
(
    SELECT SUM(CAST(B AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards
    WHERE B NOT IN
          (
              SELECT value FROM cte
          )
          AND BoardID IN ( @WinCol, @WinRow )
    UNION ALL
    SELECT SUM(CAST(I AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards
    WHERE I NOT IN
          (
              SELECT value FROM cte
          )
          AND BoardID IN ( @WinCol, @WinRow )
    UNION ALL
    SELECT SUM(CAST(N AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards
    WHERE N NOT IN
          (
              SELECT value FROM cte
          )
          AND BoardID IN ( @WinCol, @WinRow )
    UNION ALL
    SELECT SUM(CAST(G AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards
    WHERE G NOT IN
          (
              SELECT value FROM cte
          )
          AND BoardID IN ( @WinCol, @WinRow )
    UNION ALL
    SELECT SUM(CAST(O AS INT)) AS ColSum
    FROM dbo.aoc_day4_Input_Boards
    WHERE O NOT IN
          (
              SELECT value FROM cte
          )
          AND BoardID IN ( @WinCol, @WinRow )
) data


-- check answer
--62,55,98,93,48,28,82,78,19,96,31,42,76,25,34,4,18,80,66,6,14,17,57,54,90,27,40,47,9,36,97,56,87,61,91,1,64,71,99,38,70,5,94,85,49,59,69,26,21
SELECT *
FROM dbo.aoc_day4_Input_Boards
WHERE boardid = 2
