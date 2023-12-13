SELECT * FROM Day08Nodes ORDER BY Node
SELECT * FROM Day08LeftRight

SELECT LEN(InstructionSet) FROM Day08LeftRight

/* Loop through, following the LR instructions until we hit 'ZZZ' */
DECLARE @Steps INT
SET @Steps = 1

DECLARE @NextNode VARCHAR(3)
SET @NextNode = 'AAA'

DECLARE @LR INT, @MaxLR INT
SET @LR = 1
SELECT @MaxLR = LEN(InstructionSet) FROM Day08LeftRight

WHILE @NextNode <> 'ZZZ'
BEGIN
    SELECT @NextNode = CASE WHEN SUBSTRING(InstructionSet,@LR,1) = 'L' THEN LNode ELSE RNode END FROM Day08Nodes n INNER JOIN Day08LeftRight l ON 1=1 WHERE Node = @NextNode
    
    SET @LR = @LR + 1
    IF @LR > @MaxLR
        SET @LR = 1
    
    SET @Steps = @Steps + 1
END

SELECT @NextNode, @Steps - 1
--15989

GO
/* Part 2 */

/* 
Looping like we did for all '**A' records until we hit all '**Z' takes too long
If we find the number of steps for each A->Z record and find their Least Common Multiple, that will be our answer
*/

DECLARE @Steps INT
SET @Steps = 1

DECLARE @LR INT, @MaxLR INT
SET @LR = 1
SELECT @MaxLR = LEN(InstructionSet) FROM Day08LeftRight

DECLARE @NextNode VARCHAR(3)

DROP TABLE IF EXISTS #Steps
CREATE TABLE #Steps (Steps INT)

DECLARE cur CURSOR FORWARD_ONLY
FOR  
    SELECT Node FROM Day08Nodes WHERE Node LIKE '%A'
OPEN cur
FETCH NEXT FROM cur INTO @NextNode

WHILE @@FETCH_STATUS = 0  
BEGIN   
    WHILE @NextNode NOT LIKE '%Z'
    BEGIN
        SELECT @NextNode = CASE WHEN SUBSTRING(InstructionSet,@LR,1) = 'L' THEN LNode ELSE RNode END FROM Day08Nodes n INNER JOIN Day08LeftRight l ON 1=1 WHERE Node = @NextNode
        
        SET @LR = @LR + 1
        IF @LR > @MaxLR
            SET @LR = 1
        
        SET @Steps = @Steps + 1
    END

    INSERT INTO #Steps VALUES (@Steps - 1)

    SET @LR = 1
    SET @Steps = 1

    FETCH NEXT FROM cur INTO @NextNode
END
CLOSE cur
DEALLOCATE cur


-- Number of steps to Z for each A record
SELECT * FROM #Steps

/*
18157
14363
19783
15989
19241
12737
*/

-- Create a User-Defined Table Type to be able to pass all the values to an LCM funciton
DROP FUNCTION IF EXISTS dbo.fnLCM_Multiple
DROP TYPE IF EXISTS LCMTableType
CREATE TYPE LCMTableType 
   AS TABLE
      ( LCMID INT IDENTITY(1,1)
      , LCMValue BIGINT );
GO

-- SQL Server doesn't have a built-in way to find LCM, so let's create one
CREATE OR ALTER FUNCTION dbo.fnLCM_Multiple (@LCM AS LCMTableType READONLY)
RETURNS BIGINT
AS 
BEGIN

    /*
    This will calculate Least Common Multiple of a table of values without requiring the computation of GCD

    1. Initialize result = 1
    2. Find a common factors of two or more table records.
    3. Multiply the result by common factor and divide all the table records by this common factor.
    4. Repeat steps 2 and 3 while there is a common factor of two or more elements.
    5. Multiply the result by reduced (or divided) table records.
    */

    DECLARE @Result BIGINT
    DECLARE @CurrentFactor BIGINT
    DECLARE @MaxValue BIGINT
    DECLARE @Factors AS TABLE (ID INT, FValue BIGINT)

    -- We need to be able to update the values as we go along, so create a copy of the table parameter, which has to be delared as read only
    INSERT INTO @Factors (ID, FValue) SELECT LCMID, LCMValue FROM @LCM

    -- Initialize result = 1
    SET @Result = 1
    SET @CurrentFactor = 2

    SELECT @MaxValue = MAX(LCMValue) FROM @LCM

    -- Find a common factors of two or more table records.
    WHILE @CurrentFactor <= @MaxValue
    BEGIN
        IF (SELECT COUNT(*) FROM @Factors WHERE FValue % @CurrentFactor = 0) >= 2
        BEGIN
            -- Multiply the result by common factor and divide all the table records by this common factor.
            UPDATE @Factors SET FValue = FValue / @CurrentFactor WHERE FValue % @CurrentFactor = 0
            SET @Result = @Result * @CurrentFactor
        END
        ELSE
            SET @CurrentFactor = @CurrentFactor + 1
    END

    -- Then multiply all reduced records
    SELECT @Result = FValue * COALESCE(@Result,1) FROM @Factors

    RETURN @Result
END

GO

SELECT * FROM #Steps

DECLARE @LCM AS LCMTableType

INSERT INTO @LCM SELECT Steps FROM #Steps
SELECT dbo.fnLCM_Multiple(@LCM)
--13830919117339