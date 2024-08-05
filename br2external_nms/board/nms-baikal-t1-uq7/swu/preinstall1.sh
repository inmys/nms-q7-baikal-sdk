#!/bin/sh

if ! grep -q 'Baikal-T1 uq7 SOM' /proc/device-tree/model; then
	echo "This update for other device!"
	exit 1
fi

exit 0
