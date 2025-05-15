# PostgreSQL Primary-Replica Demo

## Start / Stop

To start the primary and replica just perform start the docker compose:

```bash
docker-compose up -d
```

Stop the  services and remove volumes:

```bash
docker-compose down -v
```

## Folder structure

* `conf`: Config files for both infra and `ProxySQL`.
* `datadir`: ProxySQL datadir, to be used while testing.
* `scripts`: Collection of scripts to assist with config/demo.
