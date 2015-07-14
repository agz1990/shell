#!/bin/ksh 
################################################################################
#文件名:
#Function:
#
#History:
# 2015-07-13   jigc create
################################################################################

ECHO="echo " 
EGREP="egrep"
CMD_LIME="$0 $*"
MODE="UNKNOW-MODE"
PACKAGE_NAME=""
CONFILE_NAME=""

EXCUTE_FLAG="NO"


AWK_FORMAT_ABS_PAHT="/home/mcb3user/jigc/shell/update_tools/package-update.awk"

help(){
cat  << EOF
########################################################################
# Author      : jigc 
# Script Name : svn-mark
# Description : 对svn改动文件进行标记
# Version     : V2.0
# Usage       : $0 -r <起始版本号>:<结束版本号|HEAD> -f <配置文件绝对路径> [-d parrten] [dirlist ... ]
#         1. parrten 需要标记为排除的文件的正则公式
#         2. dirlist 需要标记的文件列表 {warn}文件夹的顺序在打包脚本中叠加处理由"左到右叠加"
# Mark Type   : 
#    [ ]   -- 不含在 dirlist 中的文件
#    [*]   -- 包含在 dirlist 中的文件
#    [!]   -- 包含在 dirlist 中的文件，并匹配 -d 参数所指定的正则公式（过滤标志）
# Log         :
#  2014.07.01   V1.0: 实现基本功能 
#  2014.11.21   V2.0：提高容错性 
#
#
########################################################################
EOF

}

# package-update.sh --create-mode --conf /home/mcb3user/jigc/shell/update_tools/update.conf  --package-name  ~/jigc/update.tgz
# ./package-update.sh --extract-mode --conf ~/shell/update_tools/update.conf  --package-name  ~/update.tgz  --backup-package-name  ~/shell/update_tools/back-xxx.tgz

# ./package-update.sh --extract-mode  --excute-update --conf ~/shell/update_tools/update.conf  --package-name  ~/update.tgz  --backup-package-name  ~/shell/update_tools/back-xxx.tgz


# 打包的临时目标路径在打包完成后将删除
TAR_PACKAGE_TMP_DIR="/tmp/package-utile-output.$$"


#获取参数##########################

#set -- `getopt cxh:bf:p:d $*` 
#eval set -- "${ARGS}"
while [ $# -gt 0 ]; 
do

	case "$1" in
	-h)
		help 
		exit 0
		;;
	--package-name)
		PACKAGE_NAME=$2
		shift 
		;;
	--backup-package-name)
		BACKUP_PACKAGE_NAME=$2
		shift 
		;;		
	--conf)
		
		CONFILE_NAME=$2 
		
		. $CONFILE_NAME
		shift 
		;;
	--debug)
		DEBUG="TRUE"
		break
		;;
	--create-mode)
		MODE="CREATE-MODE"
		;;
	--extract-mode)
		MODE="EXTRACT-MODE"
		 ;;
	--excute-update)
		EXCUTE_FLAG="YES"
		;;
    --)
		
		break
		;;
    esac
shift
done

###################################




#main 入口#################################

create_init(){


$ECHO "################################################################################"
$ECHO "# SVN 版本号           	  : ${SVN_VERSION}" 
$ECHO "# SVN 基础路径             : ${SVN_BASE_FIEL_DIR}"
$ECHO "# 更新压缩包绝对值路径     : ${PACKAGE_NAME}" 
$ECHO "# 配置文件绝对值路径       : ${CONFILE_NAME}"
$ECHO "# 生产的目标路径           : ${DEST_DIR}"
$ECHO "# 压缩文件临时文件夹       : ${TAR_PACKAGE_TMP_DIR}"
$ECHO "# 命令行                   : ${CMD_LIME}"
$ECHO "################################################################################"


	[ ! -d ${DEST_DIR} ] && mkdir -p ${DEST_DIR}
	cd $SVN_BASE_FIEL_DIR 
	

}

clean_up(){
	$ECHO "rm ${DEST_DIR}"
}


my_copy(){
	source_file=$1
	dest_file=$2
	dest_dir=`dirname $dest_file` 
	[ ! -d "${dest_dir}" ] && $ECHO "mkdir -p ${dest_dir} "   | sh 
	$ECHO "cp ${source_file} ${dest_file}"   | sh
	if [ $? -eq 0 ]; then
		$ECHO  "[MESSAGE]	COPY SOURCE FILE:[ ${source_file} ] SUCCESS..."
	else
		$ECHO  "[ERROR]	COPY SOURCE FILE:[ ${source_file} ] FAILT..."
		exit 1
	fi
	
}




# 打包更新的文件



create_process(){
	create_init		# 初始化函数
	
	# 执行钩子函数
	$ECHO "\n\n[HOOK PRE-PACKAGE] BEGINE...\n" 
	(pre_package)
	$ECHO "\n[HOOK PRE-PACKAGE] END...\n\n" 
	
	# 拷贝更新文件到指定文件夹
	file_list | awk  -f ${AWK_FORMAT_ABS_PAHT} TAR_PACKAGE_TMP_DIR=${TAR_PACKAGE_TMP_DIR} DEST_DIR=${DEST_DIR} | while read line ; do
		
		$ECHO  $line | $EGREP -q "^CP"
		if [ $? -eq 0 ]; then
			$ECHO $line | read xxx src_file dest_file
			if [  -f $src_file -a ! -z $dest_file ];then
				my_copy $src_file $dest_file
			fi
		fi
		
		$ECHO  $line | $EGREP -q "^(ERROR|WARMING|DEBUG)"
		if [ $? -eq 0 ]; then
			$ECHO "[MESSAGE] $line"
		fi

		
	done  
	
	
	# 切换工作目录到生成文件的根目录
	
	[ ! -d ${TAR_PACKAGE_TMP_DIR} ] && mkdir -p ${TAR_PACKAGE_TMP_DIR}
	$ECHO "[MESSAGE]	改变路径到压缩文件临时文件夹下: ${TAR_PACKAGE_TMP_DIR}\n\n"
	cd ${TAR_PACKAGE_TMP_DIR} 
	
	
	$ECHO  "[MESSAGE]	开始打包所有需要更新的文件:[ ${PACKAGE_NAME} ] ...\n"
	# 打包的时候需要过滤文件夹
	sync
	# find . -type f | xargs tar -cvf package.tgz 
	tar -cvf ${PACKAGE_NAME} *
	
	if [ $? -eq 0 ]; then
		_file_cnt=`tar -tf ${PACKAGE_NAME} | sed -e '/\/$/d' | wc -l`
		$ECHO  "\n[MESSAGE]	PACKAGE FILE:[ ${PACKAGE_NAME}(total:$_file_cnt) ] SUCCESS..."
	else
		$ECHO  "\n[ERROR]	PACKAGE FILE:[ ${PACKAGE_NAME} ] FAILT..."
		exit 1
	fi
	
	
	
	# 执行钩子函数
	$ECHO "\n\n[HOOK AFTER-PACKAGE] BEGINE...\n" 
	(after_package)
	$ECHO "\n[HOOK AFTER-PACKAGE] END...\n\n" 
	

}

extract_init(){

	cd /
$ECHO "################################################################################"
$ECHO "# 新压缩包绝对值路径       : ${PACKAGE_NAME}" 
$ECHO "# 备份压缩包绝对路径       : ${BACKUP_PACKAGE_NAME}" 
$ECHO "# 配置文件绝对值路径       : ${CONFILE_NAME}"
$ECHO "# 生产的目标路径           : ${DEST_DIR}"
$ECHO "# 压缩文件临时文件夹       : ${TAR_PACKAGE_TMP_DIR}"
$ECHO "# 执行备份                 : ${EXCUTE_FLAG}"
$ECHO "# 命令行                   : ${CMD_LIME}"
$ECHO "################################################################################"


}


extract_process(){
	extract_init
	
	# 执行钩子函数
	$ECHO "\n\n[HOOK PRE-PACKAGE] BEGINE...\n" 
	(pre_backup)
	$ECHO "\n[HOOK PRE-PACKAGE] END...\n\n" 
	

	
	_update_cnt=0
	_add_cnt=0
	
	
	tar -tf $PACKAGE_NAME | sed -e '/\/$/d' | while read file; do
		if [ -f $file ]; then
			let "_update_cnt += 1"
			$ECHO  "[MESSAGE]	FILE:[ /${file} ] WILL BE UPDATE ..."
			
			
			if [ "${EXCUTE_FLAG}" = "YES" ]; then
				my_copy "/$file"  "${TAR_PACKAGE_TMP_DIR}/$file"
			fi
		else
			let "_add_cnt += 1"
			$ECHO  "[WARNMING]	FILE:[ /${file} ] WILL BE ADD..."
			exit 1
		fi
	done
	let "_total = _update_cnt + _add_cnt"
	
	# 打印总结信息
	$ECHO  "\n[WARMING]	***  Total(${_total}), Update(${_update_cnt}),  Add(${_add_cnt}) ***\n"
	
	
	
	if [ "${EXCUTE_FLAG}" = "YES" ]; then
		# 备份原文件 
		$ECHO "[MESSAGE]	改变路径到压缩文件临时文件夹下: ${TAR_PACKAGE_TMP_DIR}\n\n"
		cd ${TAR_PACKAGE_TMP_DIR} 
		
		$ECHO  "[MESSAGE]	开始备份所有需要更新的文件:[ ${BACKUP_PACKAGE_NAME} ] ...\n"
		sync
		# find . -type f | xargs tar -cvf package.tgz 
		tar -cvf ${BACKUP_PACKAGE_NAME} *
		
		if [ $? -eq 0 ]; then
			_file_cnt=`tar -tf ${BACKUP_PACKAGE_NAME} | sed -e '/\/$/d' | wc -l`
			$ECHO  "\n[MESSAGE]	PACKAGE FILE:[ ${BACKUP_PACKAGE_NAME}(total:$_file_cnt) ] SUCCESS..."
		else
			$ECHO  "\n[ERROR]	PACKAGE FILE:[ ${BACKUP_PACKAGE_NAME} ] FAILT..."
			exit 1
		fi
	else
		# 备份原文件 
		$ECHO "[MESSAGE]	改变路径到压缩文件临时文件夹下: ${TAR_PACKAGE_TMP_DIR}\n\n"
		
		$ECHO  "[MESSAGE]	开始备份所有需要更新的文件:[ ${BACKUP_PACKAGE_NAME} ] ...\n"
		
	fi
	
	
	
	
	# 执行钩子函数
	$ECHO "\n\n[HOOK PRE-PACKAGE] BEGINE...\n" 
	(after_backup)
	$ECHO "\n[HOOK PRE-PACKAGE] END...\n\n" 
	
}


case "${MODE}" in
	
	"CREATE-MODE")
		create_process
		break
		;;
	"EXTRACT-MODE")
		extract_process
		break
		;;
	--|*)
		help
		break
		;;
esac
