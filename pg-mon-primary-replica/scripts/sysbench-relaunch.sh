#!/bin/bash

while true; do
	date "+%Y.%m.%d %H:%M:%S.%3N"
	sysbench --db-driver=pgsql --db-ps-mode=disable --skip-trx=1 --pgsql-user=postgres\
		--pgsql_password=postgres --pgsql-db=sysbench --pgsql-host=127.0.0.1 --pgsql-port=6133\
		--rate=1000 --time=0 --tables=10 --table-size=1000 --threads=16 --report-interval=1\
		--pgsql-sslmode="disable" oltp_read_only run
done
