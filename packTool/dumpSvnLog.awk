#!/usr/bin/awk -f

########################################################################
# Author      : jigc 
# Script Name : dumpSvnLog.awk
# Date        : 2014-12-01
# Description : 解析 svn log 命令生成原始数据表
# Version     : V1.0
# Usage       : 
# Log:
#
########################################################################

BEGIN { 
	FS="[\t |]+"
	author=""
	revision=""
	date=""
	
}
NF > 7 && /^r.*\+0800/ {

	revision=substr($1,2)
	author=$2
	date=$3 " " $4
}

1 == match($3, SVN_SUFFIX) && /^   (M|A|D) /{
	file=substr($3, length(SVN_SUFFIX)+2)
	if(length(file) > 0 )
	{
		print  revision " " $2 "\t<filetype>\t" author "\t" date " " file
	}
}
