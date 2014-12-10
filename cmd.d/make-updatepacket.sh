#!/bin/sh
TAR_NAME=$1
SVNLOG=$2

until [ -z "$3" ]; do
	DIR_NAME=$3
	if [ -d "${DIR_NAME}" ]; then 
		
		if [ -z "${GREP_STR}" ]; then
			GREP_STR=${DIR_NAME}
		else
			GREP_STR="${GREP_STR}|${DIR_NAME}"
		fi
		#组装转换路径的tar命令
		TRANS_FORM="${TRANS_FORM} --transform=s|${DIR_NAME}/||g"
		#组装除去SVN路径头信息的SED命令
		SED_STR="${SED_STR}s|.*${DIR_NAME}|${DIR_NAME}|;"
		
	else
		echo "Can't Not Fount Directory: ${DIR_NAME}"
	fi
	shift
done

#组装排除文件
if [ ! -z "${lng}" ]; then
	EXCLUDE_STR="--exclude=LANGUAGE.[^${lng}] --exclude=[^${lng}]_*.wav"
fi

for line in ${TAR_EXCLUDE}; do
	EXCLUDE_STR="${EXCLUDE_STR}  --exclude=${line}"
done


svn log -r $SVNLOG -v -q | \
egrep "(M|A) .*(${GREP_STR})" | \
awk '{print $2}' | \
sort -u | sed -e "$SED_STR" | xargs tar -zcvf  ${TAR_NAME} ${TRANS_FORM} ${EXCLUDE_STR}