#!/bin/bash

set -e

PROXY_CONF_DIR=$(dirname $(realpath $0))/../conf/proxysql

echo "[$(date)] Configuring PostgreSQL Users ..."
mysql --prompt="admin> " -uradmin -pradmin --table -h127.0.0.1 -P6032 < $PROXY_CONF_DIR/pgsql_users.sql
echo "[$(date)] Configuring PostgreSQL Monitoring users ..."
mysql --prompt="admin> " -uradmin -pradmin --table -h127.0.0.1 -P6032 < $PROXY_CONF_DIR/monitor_user.sql
echo "[$(date)] Configuring PostgreSQL Servers ..."
mysql --prompt="admin> " -uradmin -pradmin --table -h127.0.0.1 -P6032 < $PROXY_CONF_DIR/servers-single_primary_replica.sql
echo "[$(date)] Configuring PostgreSQL Replication Hostgroups ..."
mysql --prompt="admin> " -uradmin -pradmin --table -h127.0.0.1 -P6032 < $PROXY_CONF_DIR/replication_hostgroups-single_primary_replica.sql
