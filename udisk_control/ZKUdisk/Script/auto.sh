#!/bin/sh


#### Uidsk Debug add by jigc 2014.10.21##########

CHECK_IS_PC=$(uname -a | grep agz)

if [ ! -z "$CHECK_IS_PC" ]; then
	UDISK_DIR='/workspace/script/udisk_control/'
	CHECK_UDISK='TRUE'
else
	sleep 5
	UDISK_DIR='/mnt/usbdisk/' 
	CHECK_UDISK=$(mount | egrep '/mnt/usbdisk.*vfat')
fi

DEBUG_SCRIPT=${UDISK_DIR}'ZKUdiskDebugScript.sh'

# 判断是否挂载了U盘, 并交出控制权
if [ ! -z "$CHECK_UDISK" ]; then
	if [ -x "${DEBUG_SCRIPT}" ]; then
		. $DEBUG_SCRIPT
		InitGlobal
		Exec
	fi
fi
	
#################################################


echo "Continue run auto.sh"
