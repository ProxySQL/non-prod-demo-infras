SELECT
    *,
    (
        FIRST_VALUE(time_start_us) OVER w - LAST_VALUE(time_start_us) OVER w
    ) / COUNT(*) over() AS INTER_QUEING_TIME
FROM (
    SELECT from_unixtime(time_start_us/1000/1000) AS time_start, *
    FROM monitor.pgsql_server_ping_log
    ORDER BY time_start_us DESC
    LIMIT 20
)
WINDOW w AS (ORDER BY time_start_us DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY time_start_us DESC
