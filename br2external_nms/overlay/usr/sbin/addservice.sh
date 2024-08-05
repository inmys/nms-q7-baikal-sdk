#!/bin/sh

if [ "$1" = "" ]
then
	echo "addservice.sh service"
	exit 1
fi

service=$1
servicename=`echo "$service" | sed 's/[0-9]\+$//'`
let ii=${#servicename}
instance=${service:$ii}

tmpdir=/tmp/services

if [ -d /var/service/${servicename}${instance} ]
then
	echo "${servicename} alreaday added"
	exit 1
fi

echo "Scheduling ${servicename} #${instance} to start..."
cp -a /etc/sv/${servicename} ${tmpdir}/${servicename}${instance}
echo ${instance} >${tmpdir}/${servicename}${instance}/instancenum
# add to runsv
ln -s ${tmpdir}/${servicename}${instance} /var/service

