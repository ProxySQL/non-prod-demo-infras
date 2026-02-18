DELETE FROM pgsql_users;
INSERT INTO pgsql_users (username,password,default_hostgroup) VALUES ('postgres','postgres',0);

LOAD PGSQL USERS TO RUNTIME;
SAVE PGSQL USERS TO DISK;
