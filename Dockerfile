FROM debian:11

# Universally required APT packages
RUN apt-get update \
        && apt-get install -y --no-install-recommends ca-certificates wget cron \
        && rm -rf /var/lib/apt/lists/*

# Installation if ARM64 architecture
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
        apt-get update \
        && apt-get install -y --no-install-recommends qrencode libfuse3-3 \
        && rm -rf /var/lib/apt/lists/* \
        && wget -q https://apps.jdbnet.co.uk/pbs-arm64/libqrencode4_4.1.1-1_arm64.deb \
        && wget -q https://apps.jdbnet.co.uk/pbs-arm64/libssl1.1_1.1.1n-0+deb11u5_arm64.deb \
        && wget -q https://apps.jdbnet.co.uk/pbs-arm64/proxmox-backup-client_2.4.2-1_arm64.deb \
        && dpkg -i libqrencode4_4.1.1-1_arm64.deb \
        && dpkg -i libssl1.1_1.1.1n-0+deb11u5_arm64.deb \
        && dpkg -i proxmox-backup-client_2.4.2-1_arm64.deb \
        && rm -f proxmox-backup-client_2.4.2-1_arm64.deb libqrencode4_4.1.1-1_arm64.deb libssl1.1_1.1.1n-0+deb11u5_arm64.deb; \
    fi

# Installation if AMD64 architecture
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
            echo "deb http://download.proxmox.com/debian/pbs-client bullseye main" > /etc/apt/sources.list.d/pbs-client.list \
            && wget -q https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg \
            && apt-get update \
            && apt-get install -y --no-install-recommends proxmox-backup-client \
            && rm -rf /var/lib/apt/lists/*; \
    fi

COPY entrypoint.sh /entrypoint.sh
COPY do_backup.sh /do_backup.sh
RUN chmod +x /entrypoint.sh && chmod +x /do_backup.sh
CMD ["/entrypoint.sh"]
