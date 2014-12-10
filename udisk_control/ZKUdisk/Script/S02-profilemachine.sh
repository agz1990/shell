#!/bin/sh

#
# 配置本地文件
#

DEBUG_LOG_FILE=$OUTPUT_DIR"/profile.log"
PROFILE_DIR=$DATA_DIR"/profile"
DEST=$MACHINE_ROOT_DIR'/profile'
[ ! -d $DEST ] && mkdir $DEST -p

MvDir $PROFILE_DIR $DEST > $DEBUG_LOG_FILE

if [ "${IS_PC}" = "no" ]; then
	MvDir $PROFILE_DIR '/'
fi

sync

return 0

