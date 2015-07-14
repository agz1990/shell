#!/bin/ksh 
################################################################################
#�ļ���:
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
# Description : ��svn�Ķ��ļ����б��
# Version     : V2.0
# Usage       : svn-mark -r <��ʼ�汾��>:<�����汾��|HEAD> -f <�����ļ�����·��> [-d parrten] [dirlist ... ]
#         1. parrten ��Ҫ���Ϊ�ų����ļ�������ʽ
#         2. dirlist ��Ҫ��ǵ��ļ��б� {warn}�ļ��е�˳���ڴ���ű��е��Ӵ�����"���ҵ���"
# Mark Type   : 
#    [ ]   -- ������ dirlist �е��ļ�
#    [*]   -- ������ dirlist �е��ļ�
#    [!]   -- ������ dirlist �е��ļ�����ƥ�� -d ������ָ��������ʽ�����˱�־��
# Log         :
#  2014.07.01   V1.0: ʵ�ֻ������� 
#  2014.11.21   V2.0������ݴ��� 
#
#
########################################################################
EOF

}


# �������ʱĿ��·���ڴ����ɺ�ɾ��
TAR_PACKAGE_TMP_DIR="/tmp/package_update_output.$$"


#��ȡ����##########################

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




#main ���#################################




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



