# Dockerized Proxmox Backup Client

## Benefits

There are two primary benefits to using this container:

- The PBS client is only officially available for Debian or Ubuntu.  This container enables backups on servers that have docker, but are either not based on Debian or do not want the app installed directly on the server.  Unraid is a great example.

- The PBS client is only officially available for AMD64 architecture.  A [workaround](https://docs.jdbnet.co.uk/Proxmox/Install-Proxmox-Backup-Client-on-ARM64/) has been bundled which allows this to also run on ARM64.  The most popular use would probably be Raspberry Pi servers.

## Usage

The [official client environment variables](https://pbs.proxmox.com/docs/backup-client.html) are leveraged, along with additional environment variables:

| Variable | Required? | Description | Example |
| -------- | :-------: | ----------- | ------- |
| CRON_SCHEDULE | Yes | Schedule you want backups to run | 00 03 * * * |
| BACKUP_TARGETS | Yes | Targets you wish to back up | etc.pxar:/etc var.pxar:/var |
| CUSTOM_HOST | No | Sets the host label on the backup server, defaults to container host name | nas1 |

### Note
When running your docker container, you need to set [the tmpfs mount](https://docs.docker.com/storage/tmpfs/) to /tmp.  If you don't, [your fidx and didx files from the previous backup will not be readable](https://forum.proxmox.com/threads/proxmox-backup-client-in-docker-subsequential-backups-never-reuse-data.107472/post-462447) and you won't get an accurate incremental backup.

### Example

```bash
docker run \
    -e BACKUP_TARGETS="home.pxar:/mnt/bob" \
    -e CRON_SCHEDULE="00 03 * * *" \
    -e PBS_REPOSITORY="root@pam!mytoken@backup.myhost.com:backup1" \
    -e PBS_PASSWORD="93ad57ba-4881-4538-9023-a2d7c24c8451" \
    -e CUSTOM_HOST="bobs-server" \
    --tmpfs /tmp \
    -v /home/bob:/mnt/bob:ro \
    -d \
    ghcr.io/fred-drake/proxmox-backup-client:latest
```
