#!/bin/sh

if [ "$1" = "" ]
then
	echo "delservice.sh service"
	exit 1
fi

service=$1

tmpdir=/tmp/services

echo "Disable service ${service}"
sv stop /var/service/${service}
rm -f /var/service/${service}
rm -rf ${tmpdir}/${service}

