\set ON_ERROR_STOP on

\connect sysbench;

DELETE FROM sbtest1;
INSERT INTO sbtest1 (k, c, pad) VALUES (1, 'x', 'y');

WITH RECURSIVE gen(n) AS (
	SELECT 1
	UNION ALL
	SELECT n + 1
	FROM gen
	WHERE n < 48000
)
INSERT INTO sbtest1 (k, c, pad)
SELECT
	(random() * 10000)::int,
	lpad(md5(random()::text), 120, 'x')::char(120),
	lpad(md5(random()::text), 60,  'y')::char(60)
FROM gen;
