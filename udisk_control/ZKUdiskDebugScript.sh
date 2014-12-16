#!/bin/sh


IsPC()
{
	CHECK_IS_PC=$(uname -a | grep agz)
	if [ ! -z "$CHECK_IS_PC" ]; then
		export IS_PC='yes'
	else
		export IS_PC='no'
	fi
}

GetNextLogCnt()
{
	LOG_CNT_FILE="${LOGDIR_ROOT}/logCount.txt"
	LOG_CNT=''
	[ ! -f "$LOG_CNT_FILE" ] && echo "NextLogTime:0001"  > $LOG_CNT_FILE
	
	export LOG_CNT=$(awk -F':0*' '{printf("%04d",$2)}' $LOG_CNT_FILE)
	
	#echo "$LOG_CNT"
	
	NEXT_LOG_CNT=$(awk -F':0*' '{printf("%04d",$2+1)}' $LOG_CNT_FILE)
	echo "NextLogTime:${NEXT_LOG_CNT}" >  $LOG_CNT_FILE

}

InitGlobal()
{
	IsPC  #设置是否是PC端标志位

	export LOGTEST='yes'
	export SCRIPT_DIR=$UDISK_DIR"ZKUdisk/Script"
	export DATA_DIR=$UDISK_DIR"ZKUdisk/Data"
	
	export MAC=$(ifconfig | awk '/^eth0[^:].*encap/{print $5}' | sed -e 's|:|-|g')	

	# 设备输出节点
	export OUTPUT_DIR=$UDISK_DIR"ZKUdisk/Output/"$MAC	


	if [ "${LOGTEST}" = "yes" ]; then
		# 设备日志存放节点
		export LOGDIR_ROOT="${UDISK_DIR}ZKUdisk/LogDir/${MAC}"
		[ ! -d $LOGDIR_ROOT ] && mkdir $LOGDIR_ROOT -p
		GetNextLogCnt
		export LOGDIR="${LOGDIR_ROOT}/${LOG_CNT}"

		[ ! -d $LOGDIR ] && mkdir $LOGDIR -p
	fi


	# 设备解文件解压根节点
	export MACHINE_ROOT_DIR=$UDISK_DIR"ZKUdisk/MachineRoot/"$MAC
	
	export RUN_LOG_FILE=$OUTPUT_DIR"/run.log"

	[ ! -d $SCRIPT_DIR ] && mkdir $SCRIPT_DIR -p
	[ ! -d $DATA_DIR ] && mkdir $DATA_DIR -p
	[ ! -d $OUTPUT_DIR ] && mkdir $OUTPUT_DIR -p
	[ ! -d $MACHINE_ROOT_DIR ] && mkdir $MACHINE_ROOT_DIR -p
	
}


MvDir()
{
	(cd $1 && tar cf - . ) | (cd $2 && tar xvpf - )
}

#
# 运行扩展初始化脚本
#
Exec()
{
	if [ -d "$SCRIPT_DIR" ]; then

		for i in $(find  $SCRIPT_DIR -name '[0-9][0-9]-*.sh' | sort) ; do
			if [ -r $i ]; then
				echo "################################################################################"
				echo "Runing: "$(basename $i)
				  . $i 
				if [ "$?" = 0 ]; then
					echo "Run "$(basename $i)" Success...."
				else
					echo "Run :"$(basename $i)" Faile...."
				fi
				echo "\n"
					
			fi
	  	done 
		echo "################################################################################"
	fi  > $RUN_LOG_FILE 
}

