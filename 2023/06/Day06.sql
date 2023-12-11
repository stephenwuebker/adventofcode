/*

Time:      7  15   30
Distance:  9  40  200


Time:        59     79     65     75
Distance:   597   1234   1032   1328
*/

DROP TABLE IF EXISTS #MOE
CREATE TABLE #MOE (RaceID INT, Victory INT)

DECLARE @T INT, @D INT, @X INT, @RaceID INT

SET @RaceID = 4
SET @T = 75
SET @D = 1328
SET @X = 1

WHILE @X < @T
BEGIN
    IF (@T-@X) * @X > @D
        INSERT INTO #MOE VALUES (@RaceID, (@T-@X) * @X)
    
    SET @X = @X + 1
END

SELECT RaceID, COUNT(*) AS ct FROM #MOE GROUP BY RaceID

SELECT 34 * 36 * 10 * 18
-- 220320


/* PART 2 */

/*
Time:      71530
Distance:  940200

Time:       59796575
Distance:   597123410321328
*/

/* 
Looping through this is too slow.

We are interested when X(T-X) > D, or X^2 - XT - D < 0

Quadratic formula FTW

*/

DECLARE @T BIGINT, @D BIGINT

SET @T = 59796575
SET @D = 597123410321328

SELECT CEILING((@T - SQRT(POWER(@T,2) - (@D *4 ))) / 2)
--12670863
SELECT FLOOR((@T + SQRT(POWER(@T,2) - (@D *4 ))) / 2)
--47125712

SELECT FLOOR((@T + SQRT(POWER(@T,2) - (@D *4 ))) / 2) - CEILING((@T - SQRT(POWER(@T,2) - (@D *4 ))) / 2) + 1
--34454850
