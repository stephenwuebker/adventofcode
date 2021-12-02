-- import data into dbo.aoc_day2

SELECT * FROM dbo.aoc_day2

-- part 1

-- Lets modify the qty data to make this easy. We'll make anything in the "up" direction negative so we can just sum things
ALTER TABLE dbo.aoc_day2 ADD units INT
UPDATE dbo.aoc_day2 SET units = qty
UPDATE dbo.aoc_day2 SET units = units * -1 WHERE direction = 'up'

-- get horizontal position
SELECT SUM(units) FROM dbo.aoc_day2 WHERE direction = 'forward'
--2010

-- get depth
SELECT SUM(units) FROM dbo.aoc_day2 WHERE direction IN ('up','down')
--1030

-- final answer
SELECT 2010*1030



--part 2

ALTER TABLE dbo.aoc_day2 ADD RowID INT IDENTITY(1,1)

SELECT * FROM dbo.aoc_day2
SELECT MAX(RowID) FROM dbo.aoc_day2

DECLARE @dir NVARCHAR(7)
DECLARE @units INT
DECLARE @aim INT
DECLARE @depth INT

SET @aim = 0
SET @depth = 0

DECLARE cur CURSOR FAST_FORWARD
    FOR SELECT direction, units FROM dbo.aoc_day2 ORDER BY RowID
OPEN cur
FETCH NEXT FROM cur INTO @dir, @units

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @dir = 'forward'
        SET @depth = @depth + (@aim * @units)
    ELSE
        SET @aim = @aim + @units

    FETCH NEXT FROM cur INTO @dir, @units
END
CLOSE cur
DEALLOCATE cur

-- get the depth. also grab the aim as a check. it should be the same as the previously calculated depth in part 1
SELECT @aim, @depth
--1034321

--final answer (the horizontal position from part 1 is still correct so just use it here)
SELECT 1034321*2010

--clean up 
DROP TABLE IF EXISTS dbo.aoc_day2