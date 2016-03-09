#!/bin/sh
#
TAPDEV="$1"
BRIDGEDEV="br0"
#
ifconfig $BRIDGEDEV deletem $TAPDEV
