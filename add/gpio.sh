#!/bin/sh

name_to_n()
{
	if ! grep -q /sys/kernel/debug /proc/mounts; then
		mount -t debugfs debugfs /sys/kernel/debug
	fi
	grep $1 /sys/kernel/debug/gpio | awk '{print $1}' | awk -F '-' '{print $2}'
}

#direction: in, out, low, high
export_gpio()
{
	name=$1
	direction=$2

	n=$(name_to_n $name)

	if [ ! -e /sys/class/gpio/gpio${n} ]; then
		echo $n>/sys/class/gpio/export
	fi
	echo ${direction}>/sys/class/gpio/gpio${n}/direction
	echo $n
}

set_gpio()
{
	n=$1
	echo 1 >/sys/class/gpio/gpio${n}/value
}

clr_gpio()
{
	n=$1
	echo 0 >/sys/class/gpio/gpio${n}/value
}

wr_gpio()
{
	n=$1
	echo $2 >/sys/class/gpio/gpio${n}/value
}

rd_gpio()
{
	n=$1
	cat /sys/class/gpio/gpio${n}/value
}

name=$1
if [ "$name" = "" ];then
	echo "usage: gpio.sh gpio_name [value]"
	exit
fi
v=$2
if [ "$2" = "" ]; then
	n=$(export_gpio ${name} in)
	v=$(rd_gpio $n)
	echo $v
	exit 0
fi
# out
d=low
if [ "$v" = "1" ]; then
	d=high
fi
n=$(export_gpio ${name} $d)
wr_gpio $n $v


