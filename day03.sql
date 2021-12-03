-- import data into dbo.aoc_day3

SELECT * FROM dbo.aoc_day3

select DISTINCT LEN(Input) FROM dbo.aoc_day3

-- part 1

-- we need 12 columns
ALTER TABLE dbo.aoc_day3 ADD
Bit01 CHAR(1),
Bit02 CHAR(1),
Bit03 CHAR(1),
Bit04 CHAR(1),
Bit05 CHAR(1),
Bit06 CHAR(1),
Bit07 CHAR(1),
Bit08 CHAR(1),
Bit09 CHAR(1),
Bit10 CHAR(1),
Bit11 CHAR(1),
Bit12 CHAR(1)


UPDATE dbo.aoc_day3 SET 
Bit01 = SUBSTRING([Input],1,1),
Bit02 = SUBSTRING([Input],2,1),
Bit03 = SUBSTRING([Input],3,1),
Bit04 = SUBSTRING([Input],4,1),
Bit05 = SUBSTRING([Input],5,1),
Bit06 = SUBSTRING([Input],6,1),
Bit07 = SUBSTRING([Input],7,1),
Bit08 = SUBSTRING([Input],8,1),
Bit09 = SUBSTRING([Input],9,1),
Bit10 = SUBSTRING([Input],10,1),
Bit11 = SUBSTRING([Input],11,1),
Bit12 = SUBSTRING([Input],12,1)


-- Calculate the most common value of each bit
DROP TABLE IF EXISTS #rate

CREATE TABLE #rate (
    Col VARCHAR(10),
    BitValue VARCHAR(1),
    Common INT
)


INSERT INTO #rate
SELECT 'bit01' AS Col, Bit01 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit01
UNION ALL
SELECT 'bit02' AS Col, Bit02 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit02
UNION ALL
SELECT 'bit03' AS Col, Bit03 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit03
UNION ALL
SELECT 'bit04' AS Col, Bit04 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit04
UNION ALL
SELECT 'bit05' AS Col, Bit05 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit05
UNION ALL
SELECT 'bit06' AS Col, Bit06 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit06
UNION ALL
SELECT 'bit07' AS Col, Bit07 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit07
UNION ALL
SELECT 'bit08' AS Col, Bit08 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit08
UNION ALL
SELECT 'bit09' AS Col, Bit09 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit09
UNION ALL
SELECT 'bit10' AS Col, Bit10 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit10
UNION ALL
SELECT 'bit11' AS Col, Bit11 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit11
UNION ALL
SELECT 'bit12' AS Col, Bit12 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit12


SELECT COUNT(*), Bit01 as BitValue, ROW_NUMBER() OVER (ORDER BY COUNT(*))
FROM dbo.aoc_day3 
GROUP BY Bit01

-- most common = 2, least common = 1
-- convert bits from binary to decimal
ALTER TABLE #rate ADD NumericVal INT
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 1 WHERE Col = 'bit12'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 2 WHERE Col = 'bit11'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 4 WHERE Col = 'bit10'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 8 WHERE Col = 'bit09'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 16 WHERE Col = 'bit08'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 32 WHERE Col = 'bit07'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 64 WHERE Col = 'bit06'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 128 WHERE Col = 'bit05'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 256 WHERE Col = 'bit04'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 512 WHERE Col = 'bit03'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 1024 WHERE Col = 'bit02'
UPDATE #rate SET NumericVal = CAST(BitValue AS INT) * 2048 WHERE Col = 'bit01'

SELECT * FROM #rate
WHERE Common = 2

SELECT * FROM #rate
WHERE Common = 1

-- gamma rate
SELECT SUM(NumericVal) FROM #rate WHERE Common = 2
--1337

-- epsilon rate
SELECT SUM(NumericVal) FROM #rate WHERE Common = 1
--2758

-- answer:
SELECT 1337 * 2758


-- part 2

ALTER TABLE dbo.aoc_day3 ADD DecimalValue INT
UPDATE dbo.aoc_day3 SET DecimalValue = 
(Bit01 * 2048) + (Bit02 * 1024) + (Bit03 * 512) + 
(Bit04 * 256) + (Bit05 * 128) + (Bit06 * 64) + 
(Bit07 * 32) + (Bit08 * 16) + (Bit09 * 8) + 
(Bit10 * 4) + (Bit11 * 2) + (Bit12 * 1) 

SELECT 'bit01' AS Col,COUNT(*),
       Bit01 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit01 DESC)
FROM dbo.aoc_day3
GROUP BY Bit01

DROP TABLE IF EXISTS #sub1
SELECT * INTO #sub1 FROM dbo.aoc_day3
WHERE Bit01 = '0'

SELECT 'bit02' AS Col,COUNT(*),
       Bit02 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit02 DESC)
FROM #sub1
GROUP BY Bit02

DROP TABLE IF EXISTS #sub2
SELECT * INTO #sub2 FROM #sub1
WHERE Bit02 = '1'

SELECT 'bit03' AS Col,COUNT(*),
       Bit03 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit03 DESC)
FROM #sub2
GROUP BY Bit03

DROP TABLE IF EXISTS #sub3
SELECT * INTO #sub3 FROM #sub2
WHERE Bit03 = '1'

SELECT 'bit04' AS Col,COUNT(*),
       Bit04 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit04 DESC)
FROM #sub3
GROUP BY Bit04

DROP TABLE IF EXISTS #sub4
SELECT * INTO #sub4 FROM #sub3
WHERE Bit04 = '0'

SELECT 'bit05' AS Col,
       COUNT(*),
       Bit05 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit05 DESC)
FROM #sub4
GROUP BY Bit05

DROP TABLE IF EXISTS #sub5
SELECT *
INTO #sub5
FROM #sub4
WHERE Bit05 = '0'

SELECT 'bit06' AS Col,
       COUNT(*),
       Bit06 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit06 DESC)
FROM #sub5
GROUP BY Bit06

DROP TABLE IF EXISTS #sub6
SELECT *
INTO #sub6
FROM #sub5
WHERE Bit06 = '0'

SELECT 'bit07' AS Col,
       COUNT(*),
       Bit07 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit07 DESC)
FROM #sub6
GROUP BY Bit07

DROP TABLE IF EXISTS #sub7
SELECT *
INTO #sub7
FROM #sub6
WHERE Bit07 = '1'

SELECT 'bit08' AS Col,
       COUNT(*),
       Bit08 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit08 DESC)
FROM #sub7
GROUP BY Bit08

DROP TABLE IF EXISTS #sub8
SELECT *
INTO #sub8
FROM #sub7
WHERE Bit08 = '1'

SELECT 'bit09' AS Col,
       COUNT(*),
       Bit09 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit09 DESC)
FROM #sub8
GROUP BY Bit09

DROP TABLE IF EXISTS #sub9
SELECT *
INTO #sub9
FROM #sub8
WHERE Bit09 = '1'

SELECT 'bit10' AS Col,
       COUNT(*),
       Bit10 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit10 DESC)
FROM #sub9
GROUP BY Bit10

DROP TABLE IF EXISTS #sub10
SELECT *
INTO #sub10
FROM #sub9
WHERE Bit10 = '1'

SELECT 'bit11' AS Col,
       COUNT(*),
       Bit11 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit11 DESC)
FROM #sub10
GROUP BY Bit11

DROP TABLE IF EXISTS #sub11
SELECT *
INTO #sub11
FROM #sub10
WHERE Bit11 = '1'

SELECT 'bit12' AS Col,
       COUNT(*),
       Bit12 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit12 DESC)
FROM #sub11
GROUP BY Bit12

DROP TABLE IF EXISTS #sub12
SELECT *
INTO #sub12
FROM #sub11
WHERE Bit12 = '1'

select * FROM #sub12

--1599


-- CO2 Scrubbing

SELECT 'bit01' AS Col,COUNT(*),
       Bit01 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit01 DESC)
FROM dbo.aoc_day3
GROUP BY Bit01

DROP TABLE IF EXISTS #sub1
SELECT * INTO #sub1 FROM dbo.aoc_day3
WHERE Bit01 = '1'

SELECT 'bit02' AS Col,COUNT(*),
       Bit02 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit02 DESC)
FROM #sub1
GROUP BY Bit02

DROP TABLE IF EXISTS #sub2
SELECT * INTO #sub2 FROM #sub1
WHERE Bit02 = '0'

SELECT 'bit03' AS Col,COUNT(*),
       Bit03 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit03 DESC)
FROM #sub2
GROUP BY Bit03

DROP TABLE IF EXISTS #sub3
SELECT * INTO #sub3 FROM #sub2
WHERE Bit03 = '1'

SELECT 'bit04' AS Col,COUNT(*),
       Bit04 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit04 DESC)
FROM #sub3
GROUP BY Bit04

DROP TABLE IF EXISTS #sub4
SELECT * INTO #sub4 FROM #sub3
WHERE Bit04 = '0'

SELECT 'bit05' AS Col,
       COUNT(*),
       Bit05 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit05 DESC)
FROM #sub4
GROUP BY Bit05

DROP TABLE IF EXISTS #sub5
SELECT *
INTO #sub5
FROM #sub4
WHERE Bit05 = '1'

SELECT 'bit06' AS Col,
       COUNT(*),
       Bit06 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit06 DESC)
FROM #sub5
GROUP BY Bit06

DROP TABLE IF EXISTS #sub6
SELECT *
INTO #sub6
FROM #sub5
WHERE Bit06 = '1'

SELECT 'bit07' AS Col,
       COUNT(*),
       Bit07 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit07 DESC)
FROM #sub6
GROUP BY Bit07

DROP TABLE IF EXISTS #sub7
SELECT *
INTO #sub7
FROM #sub6
WHERE Bit07 = '0'

SELECT 'bit08' AS Col,
       COUNT(*),
       Bit08 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit08 DESC)
FROM #sub7
GROUP BY Bit08

DROP TABLE IF EXISTS #sub8
SELECT *
INTO #sub8
FROM #sub7
WHERE Bit08 = '0'

SELECT 'bit09' AS Col,
       COUNT(*),
       Bit09 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit09 DESC)
FROM #sub8
GROUP BY Bit09

DROP TABLE IF EXISTS #sub9
SELECT *
INTO #sub9
FROM #sub8
WHERE Bit09 = '0'

SELECT 'bit10' AS Col,
       COUNT(*),
       Bit10 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit10 DESC)
FROM #sub9
GROUP BY Bit10

DROP TABLE IF EXISTS #sub10
SELECT *
INTO #sub10
FROM #sub9
WHERE Bit10 = '1'

SELECT 'bit11' AS Col,
       COUNT(*),
       Bit11 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit11 DESC)
FROM #sub10
GROUP BY Bit11

DROP TABLE IF EXISTS #sub11
SELECT *
INTO #sub11
FROM #sub10
WHERE Bit11 = '0'

SELECT 'bit12' AS Col,
       COUNT(*),
       Bit12 AS BitValue,
       ROW_NUMBER() OVER (ORDER BY COUNT(*), Bit12 DESC)
FROM #sub11
GROUP BY Bit12

DROP TABLE IF EXISTS #sub12
SELECT *
INTO #sub12
FROM #sub11
WHERE Bit12 = '0'

select * FROM #sub12

--2756

--answer
select 1599 * 2756