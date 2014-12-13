#!/bin/sh

# 采集指纹模式不打开全局调试日志
export LOGTEST='no'

echo 'I am Runing....'
if [ "$IS_PC" = 'yes' ]; then
	DB_FILE="/tftpboot/ZKDB.db"
	#PC端调试不复制指纹图片
	export COLLECT_FINGER_FLAG='FALSE'
	export FINGER_BMP_FILE="/tftpboot/finger.bmp"
else
	DB_FILE="/mnt/mtdblock/data/ZKDB.db"
	export COLLECT_FINGER_FLAG='TRUE'
fi
	

#原始日志存放路径
export RAW_BIO_LOG_FILE="$LOGDIR/rawbio.log"

#指纹图片存放路径
export FINGER_BMP_FILE_DIR="$LOGDIR/finger/"
[ ! -d "$FINGER_BMP_FILE_DIR" ] && mkdir "$FINGER_BMP_FILE_DIR" -p

#用户数据库文件
export USER_DB_FILE="${LOGDIR}/usermap.txt"

#清空用户数据库文件
> $USER_DB_FILE 

case `uname -n` in
	"ZMM100" )
		SQLIET="/mnt/mtdblock/data/sqlite3_arm"
		ECHO="echo -e"
		;;
	"ZMM220" ) 
		SQLIET="/mnt/mtdblock/data/sqlite3_mips"
		ECHO="echo -e"
		;;
	"(none)" ) 
		SQLIET="/mnt/mtdblock/data/sqlite3_mips"
		ECHO="echo -e"
		;;
	* ) 
		SQLIET="sqlite3"
		ECHO="echo"
	;;
esac


DumpUserMap (){

	$SQLIET  $DB_FILE  1>/dev/null  <<-Cmd-of-message
	.output ${USER_DB_FILE}
	select id,user_pin,name from user_info;
	.q
	Cmd-of-message
}

DumpUserMap 

return 0
