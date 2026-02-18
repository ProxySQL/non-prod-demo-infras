SET pgsql-monitor_password='proxymon';
SET pgsql-monitor_username='proxymon';

LOAD PGSQL VARIABLES TO RUNTIME;
SAVE PGSQL VARIABLES TO DISK;
