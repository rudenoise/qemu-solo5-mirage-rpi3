#!/bin/sh
set -x

switch=br0

if [ -n "$1" ];then
    /usr/bin/sudo /usr/sbin/tunctl -u `whoami` -t $1
    /usr/bin/sudo /sbin/ip link set $1 up
    /usr/bin/sudo /sbin/ifconfig tap0 10.0.0.1/24
    exit 0
else
    echo "Error: no interface specified"
    exit 1
fi
