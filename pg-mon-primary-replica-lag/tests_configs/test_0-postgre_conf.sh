#!/bin/bash

set -e

POSTGRE_SETUP_DIR=$(dirname $(realpath $0))/../scripts/

echo "[$(date)] Setting up interface throttling for primary ..."
$POSTGRE_SETUP_DIR/setup_primary_vintf_throttle.sh

echo "[$(date)] Creating table structures for testing ..."
PGPASSWORD=postgres ON_ERROR_STOP=1 psql -h127.0.0.1 -p15432 -Upostgres < $POSTGRE_SETUP_DIR/create_pt_table.sql
PGPASSWORD=postgres ON_ERROR_STOP=1 psql -h127.0.0.1 -p15432 -Upostgres < $POSTGRE_SETUP_DIR/create_test_table.sql
