-- Set sensible defaults for manual/automated testing
SET pgsql-monitor_replication_lag_interval=1000;
SET pgsql-monitor_replication_lag_count=5;

LOAD PGSQL VARIABLES TO RUNTIME;
SAVE PGSQL VARIABLES TO DISK;
