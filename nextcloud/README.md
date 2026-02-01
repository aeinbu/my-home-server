# Nextcloud AIO — Access & Administration

This document describes how to access and administer the Nextcloud AIO master container deployed under `/home/arjan/containers/nextcloud`.

## URLs
- Web UI (user): https://nextcloud.lab  (port 443)
- AIO admin/setup console: https://nextcloud.lab:8443 (Use https://192.168.1.134:8443)

> Ensure `nextcloud.lab` DNS points to the macvlan IP assigned in `docker-compose.yaml`.

## Start / Stop / Restart
From the `nextcloud` folder:

```bash
cd /home/arjan/containers/nextcloud
# Start in background
docker compose up -d
# Stop
docker compose down
# Restart
docker compose restart
# View status
docker compose ps
```

## Certificates
To generate a self-signed cert (lab):
```bash
cd /home/arjan/containers
./create-domain-cert.sh nextcloud nextcloud.lab
```

## Networking
- Master container is attached to `my-macvlan-network` with IP `192.168.1.134` (see `docker-compose.yaml`).
- Internal helper containers use Docker bridge networks managed by the AIO master.

## Admin account & initial setup
- On first access go to: `https://nextcloud.lab:8443` and complete the AIO setup.
- The setup UI lets you create the admin user and configure the internal DB and storage.
- If you specified an admin username/password via environment variables in the compose file, use those.

## Common admin tasks
- Enter the master container shell:

```bash
docker exec -it nextcloud-aio-mastercontainer /bin/sh
# or /bin/bash if available
```

- Update AIO image (pull then recreate):

```bash
docker compose pull
docker compose up -d
```

- Create/restore backups: the AIO stores configuration in the named volume `nextcloud_aio_mastercontainer` (mounted at `/mnt/docker-aio-config` inside the master). You can back it up by exporting the volume or using the master container's built-in backup commands (check AIO docs).

Simple volume backup example:

```bash
# Create a tarball of the config volume
docker run --rm \
  -v nextcloud_aio_mastercontainer:/data \
  -v $(pwd):/backup alpine \
  sh -c "cd /data && tar czf /backup/nextcloud-aio-config.tar.gz ."
```
