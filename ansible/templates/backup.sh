#!/bin/bash

# Pool with the data that needs a backup
MASTERPOOL="dataPool"

# Backup-Pools
BACKUPPOOLS=("backupPool" "backupPool2" "backupPool3" "backupPool4")

# zfs file systems to backup
BACKUPFILESYSTEMS=("docker" "personal" "backup" "media")

# pathes needed
LOGFILE="/var/log/backup.log"
SYNCOID="/usr/sbin/syncoid"
PRUNE="/usr/local/bin/zfs-prune-snapshots"

# -------------- program, don't change ---------------

for BACKUPPOOL in ${BACKUPPOOLS[@]}
do
        isOnline=$(/sbin/zpool status $BACKUPPOOL | grep -i 'state: ONLINE' | wc -l)

        if [ $isOnline -ge 1 ]
                then
                        echo "$(date) - $BACKUPPOOL is online. Starting backup" >> $LOGFILE

                        # sync snapshots to backup pool
                        for BACKUPSYS in ${BACKUPFILESYSTEMS[@]}
                        do
                                echo "$(date) - Starting backup of $MASTERPOOL/$BACKUPSYS to $BACKUPPOOL" >> $LOGFILE
                                $SYNCOID $MASTERPOOL/$BACKUPSYS $BACKUPPOOL/backups/$BACKUPSYS --no-sync-snap >> $LOGFILE 2>&1
                                echo "$(date) - Backup of $MASTERPOOL/$BACKUPSYS to $BACKUPPOOL is done" >> $LOGFILE
                        done

                        # cleanup
                        echo "$(date) - Starting cleanup of backup pool $BACKUPPOOL"
                        $PRUNE -p 'zfs-auto-snap_frequent' 1h $BACKUPPOOL >> $LOGFILE 2>&1
                        $PRUNE -p 'zfs-auto-snap_hourly' 2d $BACKUPPOOL >> $LOGFILE 2>&1
                        $PRUNE -p 'zfs-auto-snap_daily' 2M $BACKUPPOOL >> $LOGFILE 2>&1
                        $PRUNE -p 'zfs-auto-snap_weekly' 3M $BACKUPPOOL >> $LOGFILE 2>&1
                        $PRUNE -p 'zfs-auto-monthly' 16w $BACKUPPOOL >> $LOGFILE 2>&1
                        # yearly kept forever
                else
                        echo "$(date) - $BACKUPPOOL is not online. Trying to import it" >> $LOGFILE
                        zpool import $BACKUPPOOL
        fi
done
echo "$(date) - script run done" >> $LOGFILE
