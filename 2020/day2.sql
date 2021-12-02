-- Problem is posted at https://adventofcode.com/2020/day/2
-- Import the input data from https://adventofcode.com/2020/day/2/input
-- Import Flat File, Column delimiter = ':', Table name = dbo.day2, Columns, PPolicy, Password

/*
For example, suppose you have the following list:

1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
Each line gives the password policy and then the password. The password policy indicates the lowest and highest number of times a given letter must appear for the password to be valid. For example, 1-3 a means that the password must contain a at least 1 time and at most 3 times.

In the above example, 2 passwords are valid. The middle password, cdefg, is not; it contains no instances of b, but needs at least 1. The first and third passwords are valid: they contain one a or nine c, both within the limits of their respective policies.

How many passwords are valid according to their policies?
*/

-- Clean up the imported data
UPDATE dbo.day2 SET PPolicy = LTRIM(RTRIM(PPolicy)), Password = LTRIM(RTRIM(Password))

-- Create an id column we can use to match on
ALTER TABLE dbo.day2 ADD RowID INT IDENTITY(1,1)

-- Build a table to parse out and store the password policy so we can check the password and determine its validity
DROP TABLE IF EXISTS #check
CREATE TABLE #check (
RowID INT,
MinTimes INT,
MaxTimes INT,
Letter CHAR(1),
Password VARCHAR(50),
Valid BIT NOT NULL DEFAULT 0
)

INSERT INTO #check
(
    RowID,
    Password
)
SELECT RowID, Password FROM dbo.day2

-- Parse out the letter to check from the policy
UPDATE c SET c.Letter = b.value
--SELECT *
FROM dbo.day2 a INNER JOIN #check c ON c.RowID = a.RowID
CROSS APPLY STRING_SPLIT(PPolicy,' ') b
WHERE ISNUMERIC(LEFT(b.value,1)) = 0

-- Letter to check has been determined. Remove it from the policy so we can parse the letter frequency
UPDATE a SET a.PPolicy = LTRIM(RTRIM(REPLACE(a.PPolicy,b.value,'')))
--SELECT *
FROM dbo.day2 a CROSS APPLY STRING_SPLIT(PPolicy,' ') b
WHERE ISNUMERIC(LEFT(b.value,1)) = 0

-- Parse out the frequency
UPDATE c SET c.MinTimes = d.MinTimes, c.MaxTimes = d.MaxTimes
--SELECT *
FROM #check c INNER JOIN (
	SELECT a.RowID, MIN(CAST(b.value AS INT)) AS MinTimes, MAX(CAST(b.value AS INT)) AS MaxTimes
	FROM dbo.day2 a CROSS APPLY STRING_SPLIT(a.PPolicy,'-') b
	GROUP BY a.RowID,a.PPolicy
) d ON d.RowID = c.RowID

-- Data check
SELECT MinTimes, MaxTimes, LEN(Password), LEN(REPLACE(Password,Letter,'')), LEN(Password) - LEN(REPLACE(Password,Letter,'')), 
CASE WHEN LEN(Password) - LEN(REPLACE(Password,Letter,'')) BETWEEN MinTimes AND MaxTimes THEN 1 ELSE 0 END AS Valid 
FROM #check

-- Now we can update the validity by checking if the required letter shows up the required amount of times
UPDATE #check SET Valid = 1 WHERE LEN(Password) - LEN(REPLACE(Password,Letter,'')) BETWEEN MinTimes AND MaxTimes


-- How many passwords are valid according to their policies?
SELECT COUNT(*) FROM #check WHERE Valid = 1




-- Part 2:
/*
Each policy actually describes two positions in the password, where 1 means the first character, 2 means the second character, and so on. 
(Be careful; Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of these positions must contain the given letter. 
Other occurrences of the letter are irrelevant for the purposes of policy enforcement.

Given the same example list from above:

1-3 a: abcde is valid: position 1 contains a and position 3 does not.
1-3 b: cdefg is invalid: neither position 1 nor position 3 contains b.
2-9 c: ccccccccc is invalid: both position 2 and position 9 contain c.
How many passwords are valid according to the new interpretation of the policies?
*/

-- Reset Validity
UPDATE #check SET Valid = 0

-- Data Check
SELECT *, SUBSTRING(Password,MinTimes,1), SUBSTRING(Password,MaxTimes,1), Letter,
CASE WHEN (SUBSTRING(Password,MinTimes,1) = Letter OR SUBSTRING(Password,MaxTimes,1) = Letter) AND SUBSTRING(Password,MinTimes,1) <> SUBSTRING(Password,MaxTimes,1) THEN 1 ELSE 0 END AS Valid
FROM #check

-- Now we can update the validity by checking if the required letter shows up in only one of the required positions
UPDATE #check SET Valid = 1 
WHERE (SUBSTRING(Password,MinTimes,1) = Letter OR SUBSTRING(Password,MaxTimes,1) = Letter) 
AND SUBSTRING(Password,MinTimes,1) <> SUBSTRING(Password,MaxTimes,1)

-- How many passwords are valid according to the new interpretation of the policies?
SELECT COUNT(*) FROM #check WHERE Valid = 1
