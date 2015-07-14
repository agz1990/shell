#!/bin/ksh 
################################################################################
#文件名:
#Function:
#
#History:
# 2015-07-13   jigc create
################################################################################

ECHO=echo 
CMD_LIME="$0 $*"
PACKAGE_NAME=""
CONFILE_NAME=""


AWK_FORMAT_ABS_PAHT="/home/mcb3user/jigc/shell/update_tools/package-update.awk"

help(){
cat  << EOF
########################################################################
# Author      : jigc 
# Script Name : svn-mark
# Description : 对svn改动文件进行标记
# Version     : V2.0
# Usage       : svn-mark -r <起始版本号>:<结束版本号|HEAD> -f <配置文件绝对路径> [-d parrten] [dirlist ... ]
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


# 打包的临时目标路径在打包完成后将删除
TAR_PACKAGE_TMP_DIR="/tmp/package_update_output.$$"


#获取参数##########################

set -- `getopt h:bf:p:d $*` 
#eval set -- "${ARGS}"
while [ $# -gt 0 ]; 
do

	case "$1" in
	-h)
		help 
		;;
	-p)
		PACKAGE_NAME=$2
		shift 
		
		;;
	-f)
		
		CONFILE_NAME=$2 
		
		. $CONFILE_NAME
		shift 
		;;
	-d)
		DEBUG="TRUE"
		break
		;;
    --)
		
		break
		;;
    esac
shift
done

###################################




#main 入口#################################




init(){

	[ ! -d ${DEST_DIR} ] && mkdir -p ${DEST_DIR}
	cd $SVN_BASE_FIEL_DIR 
	

}

clean_up(){
	rm ${DEST_DIR}
}



$ECHO "################################################################################"
$ECHO "# SVN_VERSION              : ${SVN_VERSION}" 
$ECHO "# SVN_BASE_FIEL_DIR        : ${SVN_BASE_FIEL_DIR}"
$ECHO "# PACKAGE_NAME             : ${PACKAGE_NAME}" 
$ECHO "# CONFILE_NAME             : ${CONFILE_NAME}"
$ECHO "# DEST_DIR                 : ${DEST_DIR}"
$ECHO "# TAR_PACKAGE_TMP_DIR      : ${TAR_PACKAGE_TMP_DIR}"
$ECHO "# CMD_LIME                 : ${CMD_LIME}"
$ECHO "################################################################################"




init 
file_list | awk  -f ${AWK_FORMAT_ABS_PAHT} # | sh -x



