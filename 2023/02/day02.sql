/* Cleanup import mess and get a GameID at least */

SELECT * FROM Import.Day02

ALTER TABLE Import.Day02 DROP COLUMN column1

ALTER TABLE Import.Day02 ADD GameID INT

SELECT *, SUBSTRING(column2,1,CHARINDEX(':',column2,1)-1) 
FROM Import.Day02

UPDATE Import.Day02 SET GameID = CAST(SUBSTRING(column2,1,CHARINDEX(':',column2,1)-1) AS INT)

/* Break out the subsets and cube data*/
DROP TABLE IF EXISTS #subsets

SELECT GameID, ordinal AS SubsetID, TRIM(REPLACE([value],SUBSTRING(column2,1,CHARINDEX(':',column2,1)),'')) AS subset_data
INTO #subsets
FROM Import.Day02
CROSS APPLY string_split(column2,';',1)

SELECT * FROM #subsets

ALTER TABLE #subsets ADD Red INT, Green INT, Blue INT

UPDATE s SET Red = CAST(LEFT(cubes,CHARINDEX(' ',cubes)) AS INT)
-- SELECT s.GameID, s.ordinal, CAST(LEFT(cubes,CHARINDEX(' ',cubes)) AS INT)
FROM (
    SELECT GameID, SubsetID, TRIM(value) AS cubes 
    FROM #subsets
    CROSS APPLY STRING_SPLIT(subset_data,',')
) sv INNER JOIN #subsets s ON sv.GameID = s.GameID and s.SubsetID = sv.SubsetID
WHERE cubes LIKE '%red%'

UPDATE s SET Green = CAST(LEFT(cubes,CHARINDEX(' ',cubes)) AS INT)
-- SELECT s.GameID, s.ordinal, CAST(LEFT(cubes,CHARINDEX(' ',cubes)) AS INT)
FROM (
    SELECT GameID, SubsetID, TRIM(value) AS cubes 
    FROM #subsets
    CROSS APPLY STRING_SPLIT(subset_data,',')
) sv INNER JOIN #subsets s ON sv.GameID = s.GameID and s.SubsetID = sv.SubsetID
WHERE cubes LIKE '%green%'

UPDATE s SET Blue = CAST(LEFT(cubes,CHARINDEX(' ',cubes)) AS INT)
-- SELECT s.GameID, s.ordinal, CAST(LEFT(cubes,CHARINDEX(' ',cubes)) AS INT)
FROM (
    SELECT GameID, SubsetID, TRIM(value) AS cubes 
    FROM #subsets
    CROSS APPLY STRING_SPLIT(subset_data,',')
) sv INNER JOIN #subsets s ON sv.GameID = s.GameID and s.SubsetID = sv.SubsetID
WHERE cubes LIKE '%blue%'

UPDATE #subsets SET Red = ISNULL(Red,0), Green = ISNULL(Green,0), Blue = ISNULL(Blue,0)

SELECT * FROM #subsets

/*
Determine which games would have been possible if the bag had been loaded with only: 

12 red cubes, 13 green cubes, and 14 blue cubes. 

What is the sum of the IDs of those games?
*/

/* Let's find which GameIDs would NOT be possible with the given bag load */

SELECT GameID FROM #subsets 
WHERE Red > 12 OR Green > 13 OR Blue > 14

/* Now we can just grab the GameIDs that are NOT in our impossible set */

SELECT SUM(GameID) FROM Import.Day02
WHERE GameID NOT IN (
    SELECT GameID FROM #subsets 
    WHERE Red > 12 OR Green > 13 OR Blue > 14
)
--2239


/* PART 2 */
/* in each game you played, what is the fewest number of cubes of each color that could have been in the bag to make the game possible? 
For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?
*/

SELECT * FROM #subsets ORDER BY GameID, SubsetID

SELECT SUM(GamePower) FROM (
SELECT GameID, MAX(Red) AS MaxRed, MAX(Green) AS MaxGreen, MAX(Blue) AS MaxBlue, MAX(Red) * MAX(Green) * MAX(Blue) AS GamePower
FROM #subsets
GROUP BY GameID
--ORDER BY GameID
) a
--83435

-- Cleanup 
DROP TABLE IF EXISTS #subsets