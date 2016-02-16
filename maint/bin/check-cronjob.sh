#!/bin/sh

if [ `uname` = "Linux" ]; then
    ECHO="echo -e"
else
    ECHO="echo "
fi

EGREP="egrep"

CMD_LINE="$0 $*"
CMD_TIME=`date`

help(){
cat  << EOF
########################################################################
# Author      : jigc@cmsz.com
# Script Name : check-cornjob.sh
# Description : cronjob检查脚本
# Version     : V1.0
# Usage       : check-cornjob.sh [-d 20151228][--log-path <path>]

         -d 指定要查询日期，如果不指定默认为当天

         --log-path <path>  指定日志所在路径

输出标记字段说明:

# Log         :
#  2016.02.15   V1.0: 实现基本功能

# 示例        :
    $ check-cronjob.sh -d 20151228 --log-path /opt/mcb/maint/log
#######################################################################
EOF

}

#获取参数##########################
# ARGS=`getopt -a -o m:h -l raw-output:raw-input:force:help -- "$@"`
#[ $? -ne 0 ] && usage
#set -- "${ARGS}"
# eval set -- "${ARGS}"
# while true
while [ $# -gt 0 ];
do
    case "$1" in
    -d)
        DATE="$2"
        shift
        ;;
    --log-path)
        LOG_PATH="$2"
        shift
        ;;

    -h|--help)
        help
        exit
        ;;

    --)
        break;
        ;;
    esac
shift
done
###################################

LOG_PATH=${LOG_PATH:='/opt/mcb/maint/log'}
DATE=${DATE:=`date +%Y%m%d`};


check_one_job(){

    __log_file=$1
    __job_times=$2
#    __log_file="${LOG_PATH}/${__job_name}.log.${DATE}"
    if [ -f ${__log_file} ]; then

        run_times=`$EGREP 'finished with return code' $__log_file | wc -l `
        success_times=`$EGREP 'finished with return code 0.##LB' $__log_file | wc -l `
        let "error_times = $run_times - $success_times"
        finish_flag='-'
        pass_flag='-'
        if [ ${__job_times} -eq ${run_times} ]; then
            finish_flag='%'
        fi

        if [ $success_times -eq $run_times ]; then
            pass_flag='%'
        fi

#        $ECHO "${finish_flag}${pass_flag}|$run_times\t$success_times\t$error_times\t`basename $__log_file `"
        printf "%s|%4d|%4d|%4d| `basename $__log_file` \n"  "${finish_flag}${pass_flag}" $__job_times $success_times $error_times
    else
        $ECHO "\t[WARN]Check File $__log_file not exist!"
    fi

}

main(){

    # 检查是否有cronjob 列表文件
    if [ -f $HOME/maint/conf/check-cronjob-list.txt ];then
        CHECT_CRONJOB_LIST_FILE=$HOME/maint/conf/check-cronjob-list.txt
    else
        CHECT_CRONJOB_LIST_FILE=$DQAS_HOME/conf/check-cronjob-list.txt
    fi

    $ECHO "################################################################################"
    $ECHO "# 查询日期         : $DATE"
    $ECHO "# 日志路径         : $LOG_PATH"
    $ECHO "# CronJob列表文件  : $CHECT_CRONJOB_LIST_FILE"
    $ECHO "# 命令行           : $CMD_LINE"
    $ECHO "# 命令执行时间     : $CMD_TIME"
    $ECHO "################################################################################"
    $ECHO

    if [ ! -f ${CHECT_CRONJOB_LIST_FILE} ];then
        $ECHO "\t[WARN] CronJob列表文件[${CHECT_CRONJOB_LIST_FILE}] 不存在, 检查所有任务!\n"
    fi

    $ECHO "##|目标|成功|失败| - 日志文件 --------------------------------------------------"

    if [ -f $CHECT_CRONJOB_LIST_FILE ]; then
        for job_conf in `cat $CHECT_CRONJOB_LIST_FILE |grep -v "^#"`; do

            job_name=${job_conf%:*}
            job_times=${job_conf##*:}
            if [ $job_name == $job_times ]; then
                job_times=0
            fi

            log_file="${LOG_PATH}/${job_name}.log.${DATE}"
            check_one_job $log_file $job_times

        done
    else
        for log_file in `ls $LOG_PATH/*+*.${DATE} 2> /dev/null`; do
            job_times=0
            check_one_job $log_file $job_times
        done
    fi
}


main