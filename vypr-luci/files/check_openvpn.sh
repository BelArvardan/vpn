#!/bin/sh

SERVICES_DIRECTORY="/etc/init.d/"
OVPN_FILE_DIRECTORY="/etc/openvpn/"
SLEEP=60
[ -z "$1" ] || SLEEP=$1
VPN=""

ping_server () {
	# SERVER=$( grep "^remote" "$OVPN_FILE_DIRECTORY$VPN.ovpn" | sed 's/^remote //g' | sed 's/ .*$//g' )
	SERVER="8.8.8.8"
	ping -w 2 -c 1 ${SERVER} >/dev/null 2>&1
	if [ ! $? = 0 ]; then
		$SERVICES_DIRECTORY$VPN restart >/dev/null 2>&1
	fi
}

run () {
	if [ -z $(pidof openvpn) ] ; then
		$SERVICES_DIRECTORY$VPN start
	else
		ping_server
	fi
}

while true; do
	if [ $(uci get vypr.general.enabled)=="1" ] && [ $(uci get hma.general.enabled)=="0" ] ; then
		VPN="vypr"
		run 
	elif [ $(uci get vypr.general.enabled)=="0" ] && [ $(uci get hma.general.enabled)=="1" ] ; then
		VPN="hma"
		run
	fi
	sleep $SLEEP
done