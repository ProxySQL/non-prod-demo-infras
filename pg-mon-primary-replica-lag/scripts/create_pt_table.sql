\set ON_ERROR_STOP on

-- For testing 'pt-heartbeat'
-- NOTE: This must be the monitordb
\connect proxymondb;

CREATE SCHEMA IF NOT EXISTS replication;

DROP TABLE IF EXISTS replication.heartbeat;

CREATE TABLE replication.heartbeat (
	ts                    varchar(30) NOT NULL,       -- USE 30 (instead of 26) for simplicity; allows time-zones
	server_id             int NOT NULL PRIMARY KEY,
	file                  varchar(255) DEFAULT NULL,  -- SHOW BINARY LOG STATUS
	position              bigint DEFAULT NULL,        -- SHOW BINARY LOG STATUS
	relay_source_log_file varchar(255) DEFAULT NULL,  -- SHOW REPLICA STATUS
	exec_source_log_pos   bigint DEFAULT NULL         -- SHOW REPLICA STATUS
);

INSERT INTO replication.heartbeat (ts, server_id) VALUES (NOW(), 1);

GRANT SELECT ON ALL TABLES IN SCHEMA replication TO proxymon;
GRANT USAGE ON SCHEMA replication TO proxymon;
