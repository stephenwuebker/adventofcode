/* Import is weird this time */

DROP TABLE IF EXISTS Import.Seeds
CREATE TABLE Import.Seeds (
    Seed BIGINT
)

INSERT INTO Import.Seeds (Seed) 
VALUES (4043382508) 
,(113348245) 
,(3817519559) 
,(177922221) 
,(3613573568) 
,(7600537) 
,(773371046) 
,(400582097) 
,(2054637767) 
,(162982133) 
,(2246524522) 
,(153824596) 
,(1662955672) 
,(121419555) 
,(2473628355) 
,(846370595) 
,(1830497666) 
,(190544464) 
,(230006436) 
,(483872831)

SELECT * FROM Import.Seeds

/*
CREATE TABLE #TestSeeds (Seed INT)
CREATE TABLE #TestS2S (ds INT, ss INT, rl INT)
INSERT INTO #TestSeeds (Seed) SELECT value FROM generate_series(1,100)
INSERT INTO #TestS2S (ds,ss,rl) VALUES (50,98,2),(52,50,48)

SELECT s.Seed, CASE WHEN ss.ss IS NULL THEN s.Seed ELSE ss.ds + (s.Seed - ss.ss) END AS Soil, *
FROM #TestSeeds s LEFT JOIN #TestS2S ss ON s.Seed BETWEEN ss.ss AND ss.ss + (ss.rl - 1)

DROP TABLE #TestS2S
DROP TABLE #TestSeeds
*/

DROP TABLE IF EXISTS #Seed_Soil
SELECT s.Seed, CASE WHEN ss.source_start IS NULL THEN s.Seed ELSE ss.destination_start + (s.Seed - ss.source_start) END AS Soil
INTO #Seed_Soil
FROM Import.Seeds s LEFT JOIN Import.Seed2Soil ss ON s.Seed BETWEEN ss.source_start AND ss.source_start + (ss.range_length - 1)

DROP TABLE IF EXISTS #Soil_Fertilizer
SELECT ss.Soil, CASE WHEN sf.source_start IS NULL THEN ss.Soil ELSE sf.destination_start + (ss.Soil - sf.source_start) END AS Fertilizer
INTO #Soil_Fertilizer
FROM #Seed_Soil ss LEFT JOIN Import.Soil2Fertilizer sf ON ss.Soil BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

DROP TABLE IF EXISTS #Fertilizer_Water
SELECT ss.Fertilizer, CASE WHEN sf.source_start IS NULL THEN ss.Fertilizer ELSE sf.destination_start + (ss.Fertilizer - sf.source_start) END AS Water
INTO #Fertilizer_Water
FROM #Soil_Fertilizer ss LEFT JOIN Import.Fertilizer2Water sf ON ss.Fertilizer BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

DROP TABLE IF EXISTS #Water_Light
SELECT ss.Water, CASE WHEN sf.source_start IS NULL THEN ss.Water ELSE sf.destination_start + (ss.Water - sf.source_start) END AS Light
INTO #Water_Light
FROM #Fertilizer_Water ss LEFT JOIN Import.Water2Light sf ON ss.Water BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

DROP TABLE IF EXISTS #Light_Temp
SELECT ss.Light, CASE WHEN sf.source_start IS NULL THEN ss.Light ELSE sf.destination_start + (ss.Light - sf.source_start) END AS Temp
INTO #Light_Temp
FROM #Water_Light ss LEFT JOIN Import.Light2Temp sf ON ss.Light BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

DROP TABLE IF EXISTS #Temp_Humidity
SELECT ss.Temp, CASE WHEN sf.source_start IS NULL THEN ss.Temp ELSE sf.destination_start + (ss.Temp - sf.source_start) END AS Humidity
INTO #Temp_Humidity
FROM #Light_Temp ss LEFT JOIN Import.Temp2Humidity sf ON ss.Temp BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

DROP TABLE IF EXISTS #Humidity_Location
SELECT ss.Humidity, CASE WHEN sf.source_start IS NULL THEN ss.Humidity ELSE sf.destination_start + (ss.Humidity - sf.source_start) END AS Location
INTO #Humidity_Location
FROM #Temp_Humidity ss LEFT JOIN Import.Humidity2Location sf ON ss.Humidity BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)


SELECT MIN([Location]) FROM #Humidity_Location
--289863851

/* Part 2 */

DROP TABLE IF EXISTS Import.SeedsRange
CREATE TABLE Import.SeedsRange (
    SeedStart BIGINT,
    RangeLength BIGINT
)

INSERT INTO Import.SeedsRange (SeedStart, RangeLength) 
VALUES (4043382508,113348245) 
,(3817519559,177922221) 
,(3613573568,7600537) 
,(773371046,400582097) 
,(2054637767,162982133) 
,(2246524522,153824596) 
,(1662955672,121419555) 
,(2473628355,846370595) 
,(1830497666,190544464) 
,(230006436,483872831)

/* 

🎵 Too many Cooks 🎵

Even parsing through each range several thousand at a time would still take like 27 hours :(

DROP TABLE IF EXISTS #Seeds
SELECT value AS Seed INTO #Seeds FROM generate_series(4043382508,4043382508+113348245-1)
SELECT * FROM Import.Seeds

*/


/* Ehhhhhhh YOLO again. Parsing through 100K at a time too 24:25:41 LOL */


DROP TABLE IF EXISTS #Seeds
CREATE TABLE #Seeds (Seed BIGINT)

DROP TABLE IF EXISTS dbo.Locations
CREATE TABLE dbo.Locations (LocationID BIGINT)

DROP TABLE IF EXISTS dbo.MinLocations
CREATE TABLE dbo.MinLocations (LocationID BIGINT)


DECLARE @Step INT
SET @Step = 100000

DECLARE @SeedStart BIGINT, @SeedStop BIGINT
DECLARE cur CURSOR FORWARD_ONLY
FOR  
    SELECT SeedStart, SeedEnd FROM Import.SeedsRange ORDER BY RangeLength
OPEN cur
FETCH NEXT FROM cur INTO @SeedStart, @SeedStop

WHILE @@FETCH_STATUS = 0  
BEGIN   

    DECLARE @CurStart BIGINT, @CurStop BIGINT
    SET @CurStart = @SeedStart
    SET @CurStop = @CurStart + @Step - 1
    TRUNCATE TABLE #Seeds

    WHILE @CurStart < @SeedStop
    BEGIN
        TRUNCATE TABLE #Seeds
        INSERT INTO #Seeds SELECT value FROM GENERATE_SERIES(@CurStart,@CurStop)

        DROP TABLE IF EXISTS #Seed_Soil
        SELECT s.Seed, CASE WHEN ss.source_start IS NULL THEN s.Seed ELSE ss.destination_start + (s.Seed - ss.source_start) END AS Soil
        INTO #Seed_Soil
        FROM #Seeds s LEFT JOIN Import.Seed2Soil ss ON s.Seed BETWEEN ss.source_start AND ss.source_start + (ss.range_length - 1)

        DROP TABLE IF EXISTS #Soil_Fertilizer
        SELECT ss.Soil, CASE WHEN sf.source_start IS NULL THEN ss.Soil ELSE sf.destination_start + (ss.Soil - sf.source_start) END AS Fertilizer
        INTO #Soil_Fertilizer
        FROM #Seed_Soil ss LEFT JOIN Import.Soil2Fertilizer sf ON ss.Soil BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

        DROP TABLE IF EXISTS #Fertilizer_Water
        SELECT ss.Fertilizer, CASE WHEN sf.source_start IS NULL THEN ss.Fertilizer ELSE sf.destination_start + (ss.Fertilizer - sf.source_start) END AS Water
        INTO #Fertilizer_Water
        FROM #Soil_Fertilizer ss LEFT JOIN Import.Fertilizer2Water sf ON ss.Fertilizer BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

        DROP TABLE IF EXISTS #Water_Light
        SELECT ss.Water, CASE WHEN sf.source_start IS NULL THEN ss.Water ELSE sf.destination_start + (ss.Water - sf.source_start) END AS Light
        INTO #Water_Light
        FROM #Fertilizer_Water ss LEFT JOIN Import.Water2Light sf ON ss.Water BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

        DROP TABLE IF EXISTS #Light_Temp
        SELECT ss.Light, CASE WHEN sf.source_start IS NULL THEN ss.Light ELSE sf.destination_start + (ss.Light - sf.source_start) END AS Temp
        INTO #Light_Temp
        FROM #Water_Light ss LEFT JOIN Import.Light2Temp sf ON ss.Light BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

        DROP TABLE IF EXISTS #Temp_Humidity
        SELECT ss.Temp, CASE WHEN sf.source_start IS NULL THEN ss.Temp ELSE sf.destination_start + (ss.Temp - sf.source_start) END AS Humidity
        INTO #Temp_Humidity
        FROM #Light_Temp ss LEFT JOIN Import.Temp2Humidity sf ON ss.Temp BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)

        DROP TABLE IF EXISTS #Humidity_Location
        SELECT ss.Humidity, CASE WHEN sf.source_start IS NULL THEN ss.Humidity ELSE sf.destination_start + (ss.Humidity - sf.source_start) END AS Location
        INTO #Humidity_Location
        FROM #Temp_Humidity ss LEFT JOIN Import.Humidity2Location sf ON ss.Humidity BETWEEN sf.source_start AND sf.source_start + (sf.range_length - 1)


        INSERT INTO dbo.Locations SELECT MIN([Location]) FROM #Humidity_Location

        
        SET @CurStart = @CurStop + 1
        SET @CurStop = @CurStart + @Step - 1
        
        IF @CurStop > @SeedStop
            SET @CurStop = @SeedStop

    END


    /* Now get the minimum of our minimum locations */
    INSERT INTO dbo.MinLocations SELECT MIN(LocationID) FROM dbo.Locations 
    TRUNCATE TABLE dbo.Locations 
    
    FETCH NEXT FROM cur INTO @SeedStart, @SeedStop
END
CLOSE cur
DEALLOCATE cur


SELECT * FROM dbo.Locations


SELECT MIN(LocationID) FROM MinLocations
--60568880


