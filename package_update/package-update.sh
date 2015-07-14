#!/bin/ksh 
################################################################################
#�ļ���:
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
# Description : ��svn�Ķ��ļ����б��
# Version     : V2.0
# Usage       : $0 -r <��ʼ�汾��>:<�����汾��|HEAD> -f <�����ļ�����·��> [-d parrten] [dirlist ... ]
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

# package-update.sh --create-mode --conf /home/mcb3user/jigc/shell/update_tools/update.conf  --package-name  ~/jigc/update.tgz
# ./package-update.sh --extract-mode --conf ~/shell/update_tools/update.conf  --package-name  ~/update.tgz  --backup-package-name  ~/shell/update_tools/back-xxx.tgz

# ./package-update.sh --extract-mode  --excute-update --conf ~/shell/update_tools/update.conf  --package-name  ~/update.tgz  --backup-package-name  ~/shell/update_tools/back-xxx.tgz


# �������ʱĿ��·���ڴ����ɺ�ɾ��
TAR_PACKAGE_TMP_DIR="/tmp/package-utile-output.$$"


#��ȡ����##########################

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




#main ���#################################

create_init(){


$ECHO "################################################################################"
$ECHO "# SVN �汾��           	  : ${SVN_VERSION}" 
$ECHO "# SVN ����·��             : ${SVN_BASE_FIEL_DIR}"
$ECHO "# ����ѹ��������ֵ·��     : ${PACKAGE_NAME}" 
$ECHO "# �����ļ�����ֵ·��       : ${CONFILE_NAME}"
$ECHO "# ������Ŀ��·��           : ${DEST_DIR}"
$ECHO "# ѹ���ļ���ʱ�ļ���       : ${TAR_PACKAGE_TMP_DIR}"
$ECHO "# ������                   : ${CMD_LIME}"
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




# ������µ��ļ�



create_process(){
	create_init		# ��ʼ������
	
	# ִ�й��Ӻ���
	$ECHO "\n\n[HOOK PRE-PACKAGE] BEGINE...\n" 
	(pre_package)
	$ECHO "\n[HOOK PRE-PACKAGE] END...\n\n" 
	
	# ���������ļ���ָ���ļ���
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
	
	
	# �л�����Ŀ¼�������ļ��ĸ�Ŀ¼
	
	[ ! -d ${TAR_PACKAGE_TMP_DIR} ] && mkdir -p ${TAR_PACKAGE_TMP_DIR}
	$ECHO "[MESSAGE]	�ı�·����ѹ���ļ���ʱ�ļ�����: ${TAR_PACKAGE_TMP_DIR}\n\n"
	cd ${TAR_PACKAGE_TMP_DIR} 
	
	
	$ECHO  "[MESSAGE]	��ʼ���������Ҫ���µ��ļ�:[ ${PACKAGE_NAME} ] ...\n"
	# �����ʱ����Ҫ�����ļ���
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
	
	
	
	# ִ�й��Ӻ���
	$ECHO "\n\n[HOOK AFTER-PACKAGE] BEGINE...\n" 
	(after_package)
	$ECHO "\n[HOOK AFTER-PACKAGE] END...\n\n" 
	

}

extract_init(){

	cd /
$ECHO "################################################################################"
$ECHO "# ��ѹ��������ֵ·��       : ${PACKAGE_NAME}" 
$ECHO "# ����ѹ��������·��       : ${BACKUP_PACKAGE_NAME}" 
$ECHO "# �����ļ�����ֵ·��       : ${CONFILE_NAME}"
$ECHO "# ������Ŀ��·��           : ${DEST_DIR}"
$ECHO "# ѹ���ļ���ʱ�ļ���       : ${TAR_PACKAGE_TMP_DIR}"
$ECHO "# ִ�б���                 : ${EXCUTE_FLAG}"
$ECHO "# ������                   : ${CMD_LIME}"
$ECHO "################################################################################"


}


extract_process(){
	extract_init
	
	# ִ�й��Ӻ���
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
	
	# ��ӡ�ܽ���Ϣ
	$ECHO  "\n[WARMING]	***  Total(${_total}), Update(${_update_cnt}),  Add(${_add_cnt}) ***\n"
	
	
	
	if [ "${EXCUTE_FLAG}" = "YES" ]; then
		# ����ԭ�ļ� 
		$ECHO "[MESSAGE]	�ı�·����ѹ���ļ���ʱ�ļ�����: ${TAR_PACKAGE_TMP_DIR}\n\n"
		cd ${TAR_PACKAGE_TMP_DIR} 
		
		$ECHO  "[MESSAGE]	��ʼ����������Ҫ���µ��ļ�:[ ${BACKUP_PACKAGE_NAME} ] ...\n"
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
		# ����ԭ�ļ� 
		$ECHO "[MESSAGE]	�ı�·����ѹ���ļ���ʱ�ļ�����: ${TAR_PACKAGE_TMP_DIR}\n\n"
		
		$ECHO  "[MESSAGE]	��ʼ����������Ҫ���µ��ļ�:[ ${BACKUP_PACKAGE_NAME} ] ...\n"
		
	fi
	
	
	
	
	# ִ�й��Ӻ���
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
