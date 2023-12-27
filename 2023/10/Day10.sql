USE AdventOfCode2023

/* 
No real idea where to start here

HT to stonebr00k for this one. I don't know anything about how spatial data works  

*/

DECLARE @pipes NVARCHAR(MAX) = REPLACE((SELECT * FROM OPENROWSET(BULK N'/var/opt/mssql/day10_input.txt', SINGLE_CLOB)_), CHAR(13), '')

-- Convert input to JSON, and also translate the symbols to numbers to enable use of the choose()-function instead of case/iif
SET @pipes = CONCAT(N'["', REPLACE(TRANSLATE(@pipes, N'S-|7FJL.', N'01234569'), NCHAR(10), N'","'), N'"]');

--PRINT @pipes

DROP TABLE IF EXISTS #tiles, #connections
CREATE TABLE #tiles (
    TileID VARCHAR(7) NOT NULL PRIMARY KEY,
    X TINYINT NOT NULL,
    Y TINYINT NOT NULL,
    Symbol TINYINT NOT NULL,
    Point AS GEOMETRY::STGeomFromText(CONCAT('Point(', TileID, ')'), 0) PERSISTED
)

CREATE TABLE #connections (
    ConnectionID VARCHAR(7) NOT NULL PRIMARY KEY,
    C1 VARCHAR(7) NOT NULL,
    C2 VARCHAR(7) NOT NULL
)

INSERT INTO #tiles (TileID, X, Y, Symbol)
SELECT CONCAT(s.[value], ' ', CAST(l.[key] AS INT) + 1), CAST(s.[value] AS TINYINT), CAST(l.[key] AS TINYINT) + CAST(1 AS TINYINT), Symbol
FROM OPENJSON(@pipes) l
CROSS APPLY GENERATE_SERIES(1,CAST(LEN(l.[value]) AS INT)) s
CROSS APPLY (VALUES(CAST(SUBSTRING(l.[value], s.[value], 1) AS TINYINT))) _(Symbol)

INSERT INTO #connections (ConnectionID, C1, C2)
SELECT TileID, CONCAT(c1.x, ' ', c1.y), CONCAT(c2.x, ' ', c2.y)
FROM #tiles t
-- Find the directions of the two connection points for each tile (S/9 and ./0 not handled) (1 = N, 2 = E, 3 = S, 4 = W)
CROSS APPLY (VALUES(CHOOSE(Symbol, 2, 1, 3, 2, 1, 1), CHOOSE(Symbol, 4, 3, 4, 3, 4, 2))) d(d1, d2)
-- From the directions, calculate xy-coordinates for the connected tiles
CROSS APPLY (VALUES(t.x + CHOOSE(d.d1, 0, 1, 0, -1), t.y + CHOOSE(d.d1, -1, 0, 1, 0))) c1(x, y)
CROSS APPLY (VALUES(t.x + CHOOSE(d.d2, 0, 1, 0, -1), t.y + CHOOSE(d.d2, -1, 0, 1, 0))) c2(x, y)
WHERE c1.x > 0 AND c1.y > 0 AND c2.x > 0 AND c2.y > 0;

--SELECT * FROM #tiles
--SELECT * FROM #connections

declare @the_loop geometry;

with pipe_crawler as (
    select src = t.TileID, c = c.ConnectionID, i = 1
    from #tiles t
    join #connections c on t.TileID = c.c1
    where t.symbol = 0
    union all
    select src = pc.c
        ,c = iif(c.c1 = pc.src, c.c2, c.c1)
        ,i = i + 1
    from pipe_crawler pc
    join #connections c on pc.c = c.ConnectionID
    where pc.src != c.ConnectionID
)

select @the_loop = geometry::STGeomFromText(concat(
    'polygon((', 
    string_agg(cast(concat(iif(i = 1, src + N',', ''), c) as varchar(max)), ','), 
    '))'
), 0)
from pipe_crawler
option(maxrecursion 0);

select part1 = @the_loop.STLength() / 2
    ,part2 = count(*)
    ,visualization = N'See "Spatial results"-tab in SSMS ->'
    ,the_loop = @the_loop
from #tiles t
where point.STWithin(@the_loop) = 1;
go