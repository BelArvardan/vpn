#!/bin/sh

URL="https://www.goldenfrog.com/openvpn/VyprVPNOpenVPNFiles.zip"
SRCFILE=$(basename $URL)
TMPFILE="/etc/openvpn/$SRCFILE"
LOCKFILE="/tmp/vypr.lock"
SRVLIST="/etc/openvpn/vypr.list"

logger -t VYPR "Started update script"

if [ -f $LOCKFILE ]; then
	logger -t VYPR "Update already running: aborting"
	exit 0
fi

touch $LOCKFILE

logger -t VYPR "Started update download"
rm "$TMPFILE"
wget-ssl --no-check-certificate "$URL" -O "$TMPFILE"
logger -t VYPR "wget $URL: $?"

# Remove broken zipfile
unzip -t "$TMPFILE" || rm "$TMPFILE"

if [ -f $TMPFILE ]; then
  unzip -l "$TMPFILE" | grep ".ovpn" | awk '{ print $4 $5 $6 }' | sed -e 's/VyprVPNOpenVPNFiles\/\(.*\).ovpn/\1/g' > "$SRVLIST"
fi

rm $LOCKFILE

logger -t VYPR "Finished update script"

exit 0
