-- First, delete existing rows
DELETE FROM pgsql_servers;

WITH RECURSIVE numbers(i) AS (
    SELECT 1
    UNION ALL
    SELECT i + 1 FROM numbers WHERE i < 6
)
INSERT INTO pgsql_servers (hostgroup_id, hostname, port, comment)
SELECT
    CASE
        WHEN (i % 2) == 0 THEN 1
        ELSE 0
    END AS hostgroup_id,
    '10.200.1.' || i AS hostname,
    5432 AS port,
    CASE
        WHEN (i % 2) == 0 THEN 'repl_server_' || i
        ELSE 'prim_server' || i
    END AS comment
FROM
    numbers;
