#!/bin/sh

if ! grep -q 'Baikal-T1 uq7 SOM' /proc/device-tree/model; then
	echo "This update for other device!"
	exit 1
fi

SMRT_STATE=`fw_printenv SMRT_STATE | cut -d '=' -f 2`
if [ "${SMRT_STATE}" = "NOT_CONFIRM" ]; then
	echo "update not allowed in NOT_CONFIRM state!"
	exit 1
fi

#ok
exit 0
