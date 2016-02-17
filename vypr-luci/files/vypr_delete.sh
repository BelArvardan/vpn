#!/bin/sh

URL="https://www.goldenfrog.com/openvpn/VyprVPNOpenVPNFiles.zip"
SRCFILE=$(basename $URL)
TMPFILE="/etc/openvpn/$SRCFILE"
LOCKFILE="/tmp/vypr_delete.lock"

if [ -f $LOCKFILE ]; then
	logger -t VYPR "Update already running: aborting"
	exit 0
fi

touch $LOCKFILE
logger -t VYPR "Started delete script"

if [ -f $TMPFILE ]; then
  rm "$TMPFILE"
fi

rm $LOCKFILE
logger -t VYPR "Finished delete script"

exit 0
