#!/bin/bash

# Backup-Pools to check the status of
BACKUPPOOLS=("backupPool" "backupPool2" "backupPool3" "backupPool4")

# needed paths
LOGFILE="/var/log/backupCheck.log"
ZFS="/sbin/zfs"

# pushover data
PO_TOKEN=abc123
PO_UK=def456

# -------------- program, don't change ---------------
hasRecentBackups=false

for BACKUPPOOL in ${BACKUPPOOLS[@]}
do
	isOnline=$(/sbin/zpool status $BACKUPPOOL | grep -i 'state: ONLINE' | wc -l)

	if [ $isOnline -ge 1 ]
	then
		echo "$(date) - Found online pool $BACKUPPOOL" >> $LOGFILE
		# find and compare latest snapshot to today
		lastestSnapshotDate=$($ZFS list -t snapshot -o name -s creation -r $BACKUPPOOL | tail -1 | egrep -o '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{4}')
		timeAtStartOfTheDay=$(date +"%Y-%m-%d"-0000)
		echo "$(date) - Lastest date from the pool $BACKUPPOOL are from $lastestSnapshotDate and today started at $timeAtStartOfTheDay" >> $LOGFILE

		if [[ "$lastestSnapshotDate" > "$timeAtStartOfTheDay" ]] ;
		then
		    echo "Backups for $BACKUPPOOL are up to date" >> $LOGFILE
		    hasRecentBackups=true
		else
			echo "Backups for $BACKUPPOOL are not up to date. Last one is from $lastestSnapshotDate" >> $LOGFILE
		fi
	fi
done

if [ "$hasRecentBackups" = true ]; then
  	echo "$(date) - Found recent backups. Run finished" >> $LOGFILE
else
	echo "$(date) - Alarm - no recent backups found!!" >> $LOGFILE
	curl -s -F "token=$PO_TOKEN" \
    -F "user=$PO_UK" \
    -F "title=No recent backups!" \
    -F "message=Unable to find recent backups on the server. Last one is from $lastestSnapshotDate" https://api.pushover.net/1/messages.json
fi