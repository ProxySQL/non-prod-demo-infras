DELETE FROM pgsql_servers;

INSERT INTO
    pgsql_servers (hostgroup_id, hostname, port, comment)
VALUES
    (0, '127.0.0.1', 15432, 'pg-primary'),
    (1, '127.0.0.1', 15433, 'pg-replica');

LOAD PGSQL SERVERS TO RUNTIME;
SAVE PGSQL SERVERS TO DISK;
