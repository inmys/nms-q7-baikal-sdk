#!/bin/sh

if [ "$2" = "" ]
then
	echo "usage: savevar.sh service varname varvalue"
	exit 1
fi
service="$1"
name="$2"
value="$3"

settingsdir=/tmp/settings

mkdir -p ${settingsdir}
configfile=${settingsdir}/${service}
configfiletmp=`mktemp`

grep -Eq "^ *${name}=" $configfile 2>/dev/null || echo "${name}=" >> $configfile
sed -e "s|^ *${name}=.*|${name}='$value'|" < $configfile > $configfiletmp
mv $configfiletmp $configfile

