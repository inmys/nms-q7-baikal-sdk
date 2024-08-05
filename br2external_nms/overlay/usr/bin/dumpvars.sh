#!/bin/sh

if [ "$1" = "" ]
then
	echo "usage dumpvars.sh service"
	exit 1
fi
#unset LS_COLORS

export SERVICE=$1
export INSTANCENUM=""
. /etc/libsh/loadsettings

set

