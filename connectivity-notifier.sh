#!/bin/bash
# Icons: /usr/share/icons/gnome/32x32

LOG_FILE=~/.connectivity-log

stringContains() {
    local _lc=${2,,}
    [ -z "$1" ] || { [ -z "${_lc##*${1,,}*}" ] && [ -n "$2" ] ;} ;
}

notify() {
	export USER=`whoami`
	export HOME=/home/$USER
	export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u ${USER} gnome-session | head -n 1)/environ | tr '\0' '\n'| sed 's/DBUS_SESSION_BUS_ADDRESS=//')
	if [ "$1" == "ONLINE" ]; then
		/usr/bin/notify-send 'BACK ONLINE' "Internet connection restored!" --icon=face-laugh
	else
		/usr/bin/notify-send 'OFFLINE' "Internet connection lost!" --icon=face-crying
	fi
}

touch -a $LOG_FILE

LAST_LOG_ENTRY=$( tail -n 1 $LOG_FILE )

if stringContains 'ONLINE' $LAST_LOG_ENTRY
then
	LAST_STATUS='ONLINE'
else
	LAST_STATUS='OFFLINE'
fi

ping -c 2 google.com > /dev/null

if [ $? != 0 ]
then
	CURRENT_STATUS='OFFLINE'
else
	CURRENT_STATUS='ONLINE'
fi

if [ "$LAST_STATUS" != "$CURRENT_STATUS" ]; then
	notify $CURRENT_STATUS
	echo $CURRENT_STATUS `LC_ALL=en_US.UTF-8 date` >> $LOG_FILE	
fi
