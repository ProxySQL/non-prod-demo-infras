DELETE FROM pgsql_replication_hostgroups;
INSERT INTO
    pgsql_replication_hostgroups (writer_hostgroup, reader_hostgroup, check_type, comment)
VALUES
    (0, 1, 'read_only', 'pg-replication');

LOAD PGSQL SERVERS TO RUNTIME;
SAVE PGSQL SERVERS TO DISK;
