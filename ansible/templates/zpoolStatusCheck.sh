#!/bin/bash

# pool to check
POOL="dataPool"

# needed paths
LOGFILE="/var/log/poolStatusCheck.log"
ZFS="/sbin/zfs"

# pushover data
PO_TOKEN="pushOverTokenFromYourAccount"
PO_UK="pushOverUserKeyFromYourAccount"

# -------------- program, don't change ---------------

if [ "$(zpool status $POOL -x)" != "pool '$POOL' is healthy" ]; then
        echo "$(date) - Alarm - zPool $POOL is not healthy" >> $LOGFILE
        curl -s -F "token=$PO_TOKEN" \
    -F "user=$PO_UK" \
    -F "title=Zpool status unhealthy!" \
    -F "message=The status of pool $POOL does not seem to healthy" https://api.pushover.net/1/messages.json
else
        echo "$(date) - Zpool $POOL status is healthy" >> $LOGFILE
fi
