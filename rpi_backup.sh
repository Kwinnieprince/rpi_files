#!/bin/sh

mount /mnt/webdav

REPOSITORY=/mnt/webdav/giraf_backup

#Check if backup is already running
if pidof -x borg >/dev/null; then
    echo "Backup already running"
    exit
fi

export BORG_PASSPHRASE='${BORG_PASSPHRASE}'

#Creating backup repository
borg create -v --stats              \
    --exclude-caches                \
    --exclude '/var/cache/*'        \
    --exclude '/var/tmp/*'          \
    $REPOSITORY::'{hostname}-{now:%Y-%m-%d}' \
    /etc                            \
    /home                           \
    /root                           \
    /var                            \

# Prune command to maintain 7 daily, 4 weekly and 6 monthly archives
borg prune -v --list $REPOSITORY --prefix '{hostname}-' \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6

umount /mnt/webdav
