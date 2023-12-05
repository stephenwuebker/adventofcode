SELECT * FROM Import.Day04

/*
winning_numbers	card_numbers
Card   1: 91 73 74 57 24 99 31 70 60  8 	89 70 43 24 62 30 91 87 60 57 90  2 27  3 31 25 39 83 64 73 99  8 74 37 49
*/


/* Clean up import data */

ALTER TABLE Import.Day04 ADD CardID INT

SELECT *  
FROM Import.Day04
CROSS APPLY STRING_SPLIT(winning_numbers,':',1)

UPDATE i SET i.CardID = CAST(TRIM(REPLACE(value,'Card','')) AS INT)
FROM Import.Day04 i CROSS APPLY STRING_SPLIT(i.winning_numbers,':',1)
WHERE ordinal = 1

UPDATE i SET i.winning_numbers = TRIM(value)
FROM Import.Day04 i CROSS APPLY STRING_SPLIT(i.winning_numbers,':',1)
WHERE ordinal = 2


/* Setup winners and card numbers tables to compare against */
SELECT *  
FROM Import.Day04

SELECT CardID, CAST(value AS INT) AS Number
INTO #winners
FROM Import.Day04
CROSS APPLY STRING_SPLIT(winning_numbers,' ')
WHERE TRIM(value)<>''

SELECT CardID, CAST(value AS INT) AS Number
INTO #cardnumbers
FROM Import.Day04
CROSS APPLY STRING_SPLIT(card_numbers,' ')
WHERE TRIM(value)<>''

SELECT * FROM #cardnumbers WHERE CardID = 1
SELECT * FROM #winners WHERE CardID = 1

SELECT SUM(Points) FROM (
    SELECT c.CardID, COUNT(*) AS Matches, POWER(2, COUNT(*)-1) AS Points
    FROM #cardnumbers c INNER JOIN #winners w ON c.CardID = w.CardID AND c.Number = w.Number
    GROUP BY c.CardID
    --ORDER BY c.CardID
) d
--20855

/* Part 2 */

DROP TABLE IF EXISTS #winningcards
SELECT c.CardID, COUNT(*) AS Matches
INTO #winningcards
FROM #cardnumbers c INNER JOIN #winners w ON c.CardID = w.CardID AND c.Number = w.Number
GROUP BY c.CardID
ORDER BY c.CardID

SELECT * FROM #winningcards
ORDER BY CardID

DROP TABLE IF EXISTS #Cards
SELECT CardID, 1 AS CardCount INTO #Cards FROM Import.Day04

SELECT * FROM #Cards

/* Let's do bad things with cursors >:) */

DROP TABLE IF EXISTS #copies
CREATE TABLE #copies (CardID INT)

/* Get winning cards and update card counts for the copies */
DECLARE @CardID INT, @Matches INT
DECLARE cur CURSOR FORWARD_ONLY
FOR  
    SELECT w.CardID, w.Matches FROM #winningcards w
    ORDER BY w.CardID
OPEN cur
FETCH NEXT FROM cur INTO @CardID, @Matches

WHILE @@FETCH_STATUS = 0  
BEGIN   

    TRUNCATE TABLE #copies

    INSERT INTO #copies SELECT value FROM GENERATE_SERIES(@CardID + 1,@CardID + @Matches)

    /* Now update card counts based on how many currently exist */
    UPDATE c SET CardCount = c.CardCount + cc.CardCount
    --SELECT *
    FROM #copies p INNER JOIN #Cards c ON p.CardID = c.CardID
    INNER JOIN #Cards cc ON cc.CardID = @CardID

    

    FETCH NEXT FROM cur INTO @CardID, @Matches
END
CLOSE cur
DEALLOCATE cur

SELECT * FROM #Cards

SELECT SUM(CardCount) FROM #Cards
--5489600
