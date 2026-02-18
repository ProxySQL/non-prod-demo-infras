# PostgreSQL Primary-Replica Demo

## Create required images

```bash
docker build -t postgres-tc:17 .
```

## Start / Stop

To start the primary and replica just perform start the docker compose:

```bash
docker-compose up -d
```

Stop the  services and remove volumes:

```bash
docker-compose down -v
```

## Test scenarios

### 1. Check replication lag actions

Setup ProxySQL config and PostgreSQL conf:

```bash
./tests_configs/test_0-postgre_conf.sh
./tests_configs/test_0-proxysql_conf.sh
```

Insert test data to trigger replication lag (this creates 10MB of data in rows):

```
PGPASSWORD=postgres ON_ERROR_STOP=1 psql -h127.0.0.1 -p15432 -Upostgres < scripts/insert_10mb_test_data.sql
```

ProxySQL should notice the slowdown in replication, to inspect, we query the monitor tables:

```proxysql.log
2026-02-18 14:49:37 PgSQL_HostGroups_Manager.cpp:2671:replication_lag_action_inner(): [WARNING] Shunning server 127.0.0.1:15433 from HG 1 with replication lag of 835 second, count number: '1'
```

```admin
admin> SELECT * FROM pgsql_server_replication_lag_log WHERE port=15433 ORDER BY time_start_us DESC LIMIT 10;
+-----------+-------+------------------+-----------------+----------+-------+
| hostname  | port  | time_start_us    | success_time_us | repl_lag | error |
+-----------+-------+------------------+-----------------+----------+-------+
| 127.0.0.1 | 15433 | 1771422634735353 | 373             | 4        | NULL  |
| 127.0.0.1 | 15433 | 1771422633735508 | 351             | 3        | NULL  |
| 127.0.0.1 | 15433 | 1771422632735460 | 362             | 2        | NULL  |
| 127.0.0.1 | 15433 | 1771422631735336 | 368             | 0        | NULL  |
| 127.0.0.1 | 15433 | 1771422630735846 | 323             | 12       | NULL  |
| 127.0.0.1 | 15433 | 1771422629735335 | 384             | 0        | NULL  |
| 127.0.0.1 | 15433 | 1771422628735437 | 424             | 0        | NULL  |
| 127.0.0.1 | 15433 | 1771422627735532 | 375             | 0        | NULL  |
| 127.0.0.1 | 15433 | 1771422626735435 | 303             | 0        | NULL  |
| 127.0.0.1 | 15433 | 1771422625735568 | 406             | 0        | NULL  |
+-----------+-------+------------------+-----------------+----------+-------+
10 rows in set (0.00 sec)
```

### 2. Check replication lag actions - pgsql-monitor_replication_lag_count

Modify the default value and perform the same insert:

```admin
SET pgsql-monitor_replication_lag_count=5;
LOAD PGSQL VARIABLES TO RUNTIME;
```

Or use the configuration provided in `test_1-proxysql_conf.sh`:

```bash
./tests_configs/test_1-proxysql_conf.sh
```

```proxysql.log
2026-02-18 14:52:01 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 4 second, count number: '1' < replication_lag_count: '5'
2026-02-18 14:52:02 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 5 second, count number: '2' < replication_lag_count: '5'
2026-02-18 14:52:03 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 6 second, count number: '3' < replication_lag_count: '5'
2026-02-18 14:52:04 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 7 second, count number: '4' < replication_lag_count: '5'
2026-02-18 14:52:05 PgSQL_HostGroups_Manager.cpp:2671:replication_lag_action_inner(): [WARNING] Shunning server 127.0.0.1:15433 from HG 1 with replication lag of 8 second, count number: '5'
```

ProxySQL now takes into account the `count` for `SHUNNING` the server.

### 3. Check replication lag actions - monitor_replication_lag_use_percona_heartbeat

Modify the default value for `monitor_replication_lag_use_percona_heartbeat`, this will make Monitor attempt
to use the defined table as a source for the replication delay:

```admin
SET pgsql-monitor_replication_lag_use_percona_heartbeat='replication.heartbeat';
LOAD PGSQL VARIABLES TO RUNTIME;
```

The table is present in both instances, with a default value imposed by `create_pt_table.sql`. Since the value
isn't updated, the `replication_lag` check should set both servers as `SHUNNED`.

```proxysql.log
2026-02-18 14:56:14 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 1232 second, count number: '1' < replication_lag_count: '5'
2026-02-18 14:56:14 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15432 from HG 0 with replication lag of 1232 second, count number: '1' < replication_lag_count: '5'
2026-02-18 14:56:15 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 1233 second, count number: '2' < replication_lag_count: '5'
2026-02-18 14:56:15 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15432 from HG 0 with replication lag of 1233 second, count number: '2' < replication_lag_count: '5'
2026-02-18 14:56:16 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 1234 second, count number: '3' < replication_lag_count: '5'
2026-02-18 14:56:16 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15432 from HG 0 with replication lag of 1234 second, count number: '3' < replication_lag_count: '5'
2026-02-18 14:56:17 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 1235 second, count number: '4' < replication_lag_count: '5'
2026-02-18 14:56:17 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15432 from HG 0 with replication lag of 1235 second, count number: '4' < replication_lag_count: '5'
2026-02-18 14:56:18 PgSQL_HostGroups_Manager.cpp:2671:replication_lag_action_inner(): [WARNING] Shunning server 127.0.0.1:15432 from HG 0 with replication lag of 1236 second, count number: '5'
2026-02-18 14:56:18 PgSQL_HostGroups_Manager.cpp:2671:replication_lag_action_inner(): [WARNING] Shunning server 127.0.0.1:15433 from HG 1 with replication lag of 1236 second, count number: '5'
```

To check that servers are properly `UNSHUNNED` should be enough to update the value in both instances:

```bash
PGPASSWORD=postgres psql -h127.0.0.1 -p15432 -Upostgres -dproxymondb -c"UPDATE replication.heartbeat SET ts = LOCALTIMESTAMP WHERE server_id=1"
```

```proxysql.log
2026-02-18 14:59:11 PgSQL_HostGroups_Manager.cpp:2695:replication_lag_action_inner(): [WARNING] Re-enabling server 127.0.0.1:15433 from HG 1 with replication lag of 0 second
2026-02-18 14:59:11 PgSQL_HostGroups_Manager.cpp:2695:replication_lag_action_inner(): [WARNING] Re-enabling server 127.0.0.1:15432 from HG 0 with replication lag of 0 second
2026-02-18 14:59:15 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 4 second, count number: '1' < replication_lag_count: '5'
2026-02-18 14:59:15 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15432 from HG 0 with replication lag of 4 second, count number: '1' < replication_lag_count: '5'
2026-02-18 14:59:16 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 5 second, count number: '2' < replication_lag_count: '5'
2026-02-18 14:59:16 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15432 from HG 0 with replication lag of 5 second, count number: '2' < replication_lag_count: '5'
2026-02-18 14:59:17 PgSQL_HostGroups_Manager.cpp:2674:replication_lag_action_inner(): [INFO] Not shunning server 127.0.0.1:15433 from HG 1 with replication lag of 6 second, count number: '3' < replication_lag_count: '5'
```

## Folder structure

* `conf`: Config files for both infra and `ProxySQL`.
* `datadir`: ProxySQL datadir, to be used while testing.
* `scripts`: Collection of scripts to assist with config/demo.
