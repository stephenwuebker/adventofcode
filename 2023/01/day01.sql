USE AdventOfCode2023

SELECT * FROM Import.Day01

SELECT calibration_values, SUBSTRING(calibration_values,PATINDEX('%[0-9]%',calibration_values),1) AS Digit1
, SUBSTRING(REVERSE(calibration_values),PATINDEX('%[0-9]%',REVERSE(calibration_values)),1) AS Digit2
INTO #out
FROM Import.Day01

SELECT * FROM #out

ALTER TABLE #out ADD cal_value INT

UPDATE #out SET cal_value = CAST(CONCAT(Digit1,Digit2) AS INT) 

SELECT * FROM #out

SELECT SUM(cal_value) FROM #out
--54951

-- Part 2 - Need to modify input to include spelled out numbers (nine = 9, etc.)
SELECT * FROM Import.Day01

ALTER TABLE Import.Day01 ADD new_calibration_values VARCHAR(100)

UPDATE Import.Day01 SET new_calibration_values = calibration_values

/*
It's not this simple because there are strings like 'twone' and 'oneight' and 'eightwo', 
so the string needs to be parsed from left to right
*/
/*
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'one','1')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'two','2')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'three','3')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'four','4')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'five','5')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'six','6')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'seven','7')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'eight','8')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'nine','9')
*/


/* 
This also doesn't work because the instructions are not clear on how overlapping words should actually be resolved.
IE 'twone' and 'oneight' and 'eightwo' actually resolve to '21','18', and '82' respectively.
*/

/*
GO 

CREATE OR ALTER FUNCTION dbo.SpelledOutToDigits (@val VARCHAR(100)) 
RETURNS VARCHAR(100) 
AS BEGIN

DECLARE @out VARCHAR(100)
DECLARE @len INT
DECLARE @start INT
DECLARE @pos INT
SET @pos = 3
SET @len = 3
SET @start = 1

WHILE @pos <= LEN(@val)
BEGIN
    IF SUBSTRING( @val, @start, @len) LIKE '%one%' OR SUBSTRING( @val, @start, @len) LIKE '%two%' OR SUBSTRING( @val, @start, @len) LIKE '%three%' OR
    SUBSTRING( @val, @start, @len) LIKE '%four%' OR SUBSTRING( @val, @start, @len) LIKE '%five%' OR SUBSTRING( @val, @start, @len) LIKE '%six%' OR
    SUBSTRING( @val, @start, @len) LIKE '%seven%' OR SUBSTRING( @val, @start, @len) LIKE '%eight%' OR SUBSTRING( @val, @start, @len) LIKE '%nine%'
        BEGIN
            SET @out = CONCAT(@out,
                REPLACE(REPLACE(REPLACE(
                    REPLACE(REPLACE(REPLACE(
                        REPLACE(REPLACE(REPLACE(SUBSTRING( @val, @start, @len),'one','1'),'two',2),'three','3')
                    ,'four','4'),'five','5'),'six','6')
                ,'seven',7),'eight','8'),'nine',9)
            )
            SET @start = @start + @len
            SET @len = 3
        END
    ELSE
        SET @len = @len + 1
    SET @pos = @pos + 1
END

IF @start < LEN(@val)
    SET @out = CONCAT(@out,SUBSTRING(@val,@start,LEN(@val)-@start+1))

RETURN (@out)

END
GO


SELECT * FROM Import.Day01 
UPDATE Import.Day01 SET new_calibration_values = dbo.SpelledOutToDigits(calibration_values)

*/

/* 
Only the first and last letters actually overlap, and really we only want the digits so.....

YOLO


*/

UPDATE Import.Day01 SET new_calibration_values = calibration_values


UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'one','o1e')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'two','t2o')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'three','t3e')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'four','f4r')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'five','f5e')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'six','s6x')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'seven','s7n')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'eight','e8t')
UPDATE Import.Day01 SET new_calibration_values = REPLACE(new_calibration_values,'nine','n9e')







DROP TABLE IF EXISTS #out
SELECT calibration_values,new_calibration_values, SUBSTRING(new_calibration_values,PATINDEX('%[0-9]%',new_calibration_values),1) AS Digit1
, SUBSTRING(REVERSE(new_calibration_values),PATINDEX('%[0-9]%',REVERSE(new_calibration_values)),1) AS Digit2
INTO #out
FROM Import.Day01

SELECT * FROM #out

ALTER TABLE #out ADD cal_value INT

UPDATE #out SET cal_value = CAST(CONCAT(Digit1,Digit2) AS INT) 

SELECT * FROM #out

SELECT SUM(cal_value) FROM #out
--55218

-- This is probably nicer than using temp tables, TBH
WITH cte AS (
    SELECT SUBSTRING(new_calibration_values,PATINDEX('%[0-9]%',new_calibration_values),1) AS Digit1
    , SUBSTRING(REVERSE(new_calibration_values),PATINDEX('%[0-9]%',REVERSE(new_calibration_values)),1) AS Digit2
FROM Import.Day01
)
SELECT SUM(CAST(CONCAT(Digit1,Digit2) AS INT)) FROM cte
--55218

/* GOLD STAR! */