#!/bin/sh

SERVICES_DIRECTORY="/etc/init.d/"
OVPN_FILE_DIRECTORY="/etc/openvpn/"
SLEEP=60
[ -z "$2" ] || SLEEP=$2

if [ $1 == "vypr" ] || [ $1 == "hma" ] ; then
	SERVER=$( grep "^remote" "$OVPN_FILE_DIRECTORY$1.ovpn" | sed 's/^remote //g' | sed 's/ .*$//g' )

	echo $SERVER

	while true; do
		ping -w 2 -c 1 ${SERVER} >/dev/null 2>&1
			if [ ! $? = 0 ]; then
				echo $SERVICES_DIRECTORY$1
				$SERVICES_DIRECTORY$1 restart >/dev/null 2>&1
			fi
		echo $SLEEP
		sleep $SLEEP
	done
else
	echo "incorrect params"
fi
