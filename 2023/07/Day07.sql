SELECT * FROM Day07

ALTER TABLE Day07 ADD HandID INT IDENTITY(1,1)

DROP TABLE IF EXISTS HandTypes
CREATE TABLE HandTypes (HandTypeID INT, HandType VARCHAR(50))

INSERT INTO HandTypes (HandTypeID, HandType) VALUES
(1,'HighCard')
,(2,'OnePair')
,(3,'TwoPair')
,(4,'ThreeOfAKind')
,(5,'FullHouse')
,(6,'FourOfAKind')
,(7,'FiveOfAKind')

SELECT * FROM HandTypes

ALTER TABLE Day07 ADD HandTypeID INT

DROP TABLE IF EXISTS #Cards
SELECT HandID, SUBSTRING(hand,1,1) AS Card1, SUBSTRING(hand,2,1) AS Card2, 
SUBSTRING(hand,3,1) AS Card3, SUBSTRING(hand,4,1) AS Card4, SUBSTRING(hand,5,1) AS Card5
INTO #Cards
FROM Day07

SELECT HandID, CardOrder, CardValue INTO #UCards 
FROM   
   (SELECT HandID, Card1, Card2, Card3, Card4, Card5
   FROM #Cards) p  
UNPIVOT  
   (CardValue FOR CardOrder IN   
      (Card1, Card2, Card3, Card4, Card5)  
)AS unpvt 
ORDER BY HandID, CardOrder 

SELECT * FROM #UCards

SELECT * FROM HandTypes

UPDATE Day07 SET HandTypeID = NULL

-- Five of a kind
UPDATE d SET HandTypeID = 7
--SELECT *
FROM Day07 d INNER JOIN (
    SELECT HandID FROM #UCards GROUP BY HandID, CardValue HAVING COUNT(*) = 5
) s ON d.HandID = s.HandID
WHERE d.HandTypeID IS NULL


-- Four of a kind
UPDATE d SET HandTypeID = 6
--SELECT *
FROM Day07 d INNER JOIN (
    SELECT HandID FROM #UCards GROUP BY HandID, CardValue HAVING COUNT(*) = 4
) s ON d.HandID = s.HandID
WHERE d.HandTypeID IS NULL


-- Full House
UPDATE d SET HandTypeID = 5
--SELECT *
FROM Day07 d INNER JOIN (
    SELECT HandID FROM #UCards
    WHERE HandID IN (
        SELECT HandID FROM #UCards GROUP BY HandID, CardValue HAVING COUNT(*) = 2
    )
    GROUP BY HandID, CardValue HAVING COUNT(*) = 3
) s ON d.HandID = s.HandID
WHERE d.HandTypeID IS NULL


-- Three of a kind
UPDATE d SET HandTypeID = 4
--SELECT *
FROM Day07 d INNER JOIN (
    SELECT HandID FROM #UCards
    WHERE HandID NOT IN (
        SELECT HandID FROM #UCards GROUP BY HandID, CardValue HAVING COUNT(*) = 2
    )
    GROUP BY HandID, CardValue HAVING COUNT(*) = 3
) s ON d.HandID = s.HandID
WHERE d.HandTypeID IS NULL


-- Two Pair
UPDATE d SET HandTypeID = 3
--SELECT *
FROM Day07 d INNER JOIN (
    SELECT HandID FROM (
        SELECT HandID, CardValue FROM #UCards 
        GROUP BY HandID, CardValue HAVING COUNT(*) = 2 
    ) d GROUP BY HandID HAVING COUNT(*) = 2
) s ON d.HandID = s.HandID
WHERE d.HandTypeID IS NULL


-- One Pair
UPDATE d SET HandTypeID = 2
--SELECT *
FROM Day07 d INNER JOIN (
    SELECT HandID FROM (
        SELECT HandID, CardValue FROM #UCards 
        GROUP BY HandID, CardValue HAVING COUNT(*) = 2 
    ) d GROUP BY HandID HAVING COUNT(*) <> 2
) s ON d.HandID = s.HandID
WHERE d.HandTypeID IS NULL

-- High Card
UPDATE Day07 SET HandTypeID = 1 WHERE HandTypeID IS NULL


DROP TABLE IF EXISTS CardValues
CREATE TABLE CardValues (CardValueID INT, CardValue CHAR(1))

INSERT INTO CardValues (CardValueID, CardValue) VALUES
(2,'2'),(3,'3'),(4,'4'),(5,'5'),(6,'6'),(7,'7'),(8,'8'),(9,'9'),(10,'T'),(11,'J'),(12,'Q'),(13,'K'),(14,'A')

SELECT * FROM CardValues

-- Now Rank Based on Card

ALTER TABLE Day07 ADD HandRank INT


DROP TABLE IF EXISTS #Ranks
SELECT d.HandID, ROW_NUMBER() OVER (ORDER BY HandTypeID, cv1.CardValueID, cv2.CardValueID, cv3.CardValueID, cv4.CardValueID, cv5.CardValueID) AS HandRank
INTO #Ranks
FROM Day07 d INNER JOIN #Cards c ON d.HandID = c.HandID
INNER JOIN CardValues cv1 ON c.Card1 = cv1.CardValue
INNER JOIN CardValues cv2 ON c.Card2 = cv2.CardValue
INNER JOIN CardValues cv3 ON c.Card3 = cv3.CardValue
INNER JOIN CardValues cv4 ON c.Card4 = cv4.CardValue
INNER JOIN CardValues cv5 ON c.Card5 = cv5.CardValue


UPDATE d SET d.HandRank = r.HandRank
--SELECT *
FROM Day07 d INNER JOIN #Ranks r ON d.HandID = r.HandID

-- Now we can get the winnings
ALTER TABLE Day07 ADD Winnings INT

UPDATE Day07 SET Winnings = bid * HandRank

SELECT SUM(Winnings) FROM Day07
--248217452


/* Part 2 */

SELECT * FROM Day07 WHERE hand LIKE '%J%' ORDER BY HandRank

ALTER TABLE Day07 ADD JokerHandTypeID INT


-- High Card with Joker becomes one pair
UPDATE Day07 SET JokerHandTypeID = HandTypeID + 1
--SELECT * FROM Day07 
WHERE hand LIKE '%J%' AND HandTypeID = 1
AND JokerHandTypeID IS NULL


-- One pair becomes three of a kind
UPDATE Day07 SET JokerHandTypeID = HandTypeID + 2
--SELECT * FROM Day07 
WHERE hand LIKE '%J%' AND HandTypeID = 2
AND JokerHandTypeID IS NULL


-- Two pair becomes a full house OR four of a kind if one pair is jokers
UPDATE d SET JokerHandTypeID = HandTypeID + 2 + (ct-1)
--SELECT *, HandTypeID + 2 + (ct-1) 
FROM Day07 d INNER JOIN (
    SELECT HandID, CardValue, COUNT(*) AS ct FROM #UCards WHERE CardValue = 'J' GROUP BY HandID, CardValue
) v ON d.HandID = v.HandID
WHERE hand LIKE '%J%' AND HandTypeID = 3
AND JokerHandTypeID IS NULL


-- Three of a kind becomes a four of a kind 
UPDATE d SET JokerHandTypeID = HandTypeID + 2
--SELECT *, HandTypeID + 2 
FROM Day07 d
WHERE hand LIKE '%J%' AND HandTypeID = 4
AND JokerHandTypeID IS NULL


-- Full House becomes five of a kind
UPDATE d SET JokerHandTypeID = HandTypeID + 2 
--SELECT *, HandTypeID + 2 
FROM Day07 d 
WHERE hand LIKE '%J%' AND HandTypeID = 5
AND JokerHandTypeID IS NULL


-- four of a kind becomes five of a kind
UPDATE d SET JokerHandTypeID = HandTypeID + 1 
--SELECT *, HandTypeID + 1
FROM Day07 d 
WHERE hand LIKE '%J%' AND HandTypeID = 6
AND JokerHandTypeID IS NULL


-- Every other hand stays the same
UPDATE Day07 SET JokerHandTypeID = HandTypeID WHERE JokerHandTypeID IS NULL


-- Now re-order and re-rank

-- Update card values to rank jokers low
ALTER TABLE CardValues ADD JokerCardValueID INT
UPDATE CardValues SET JokerCardValueID = CardValueID
UPDATE CardValues SET JokerCardValueID = 1 WHERE CardValue = 'J'
SELECT * FROM CardValues


ALTER TABLE Day07 ADD JokerHandRank INT


DROP TABLE IF EXISTS #Ranks
SELECT d.HandID, ROW_NUMBER() OVER (ORDER BY JokerHandTypeID, cv1.JokerCardValueID, cv2.JokerCardValueID, cv3.JokerCardValueID, cv4.JokerCardValueID, cv5.JokerCardValueID) AS HandRank
INTO #Ranks
FROM Day07 d INNER JOIN #Cards c ON d.HandID = c.HandID
INNER JOIN CardValues cv1 ON c.Card1 = cv1.CardValue
INNER JOIN CardValues cv2 ON c.Card2 = cv2.CardValue
INNER JOIN CardValues cv3 ON c.Card3 = cv3.CardValue
INNER JOIN CardValues cv4 ON c.Card4 = cv4.CardValue
INNER JOIN CardValues cv5 ON c.Card5 = cv5.CardValue


UPDATE d SET d.JokerHandRank = r.HandRank
--SELECT *
FROM Day07 d INNER JOIN #Ranks r ON d.HandID = r.HandID

-- Now we can get the winnings
ALTER TABLE Day07 ADD JokerWinnings INT

UPDATE Day07 SET JokerWinnings = bid * JokerHandRank

SELECT SUM(JokerWinnings) FROM Day07
--245576185

