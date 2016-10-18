#!/bin/sh

URL="https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip"
SRCFILE=$(basename $URL)
TMPFILE="/etc/openvpn/$SRCFILE"
LOCKFILE="/tmp/ivpn.lock"
SRVLIST="/etc/openvpn/ivpn.list"

logger -t IVPN "Started update script"

if [ -f $LOCKFILE ]; then
	logger -t IVPN "Update already running: aborting"
	exit 0
fi

touch $LOCKFILE

logger -t IVPN "Started update download"
rm "$TMPFILE"
wget-ssl --no-check-certificate "$URL" -O "$TMPFILE"
logger -t IVPN "wget $URL: $?"

# Remove broken zipfile
unzip -t "$TMPFILE" || rm "$TMPFILE"

if [ -f $TMPFILE ]; then
  unzip -l "$TMPFILE" | grep ".ovpn" | awk '{ print $4 }' | sed 's/.ovpn//' > "$SRVLIST"
fi

rm $LOCKFILE

logger -t IVPN "Finished update script"

exit 0
