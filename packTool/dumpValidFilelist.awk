#!/user/bin/awk -f

########################################################################
# Author      : jigc 
# Script Name : dumpValidFilelist.awk
# Date        : 2014-12-01
# Description : 对svn提交文件进行过滤、分类
# Version     : V1.0
# Usage       : 
# Log:
#
########################################################################

BEGIN { 
	FS="[\t |]+"
	total=0
	valid=0
	invalid=0
	exclude=0
	
	#validHead=" [\033[32m*\033[0m]"
	#excludeHead=" [\033[31m!\033[0m]"

	validHead=" [*]"
	excludeHead=" [!]"
	invalidHead=" [ ]"
}

NF = 7 {

	validFlag=0
	sourcefile=$7
	if(match($7, DEST_DIR_PATTERN)){	
		
		basename=$7
		sub(/.*\//,"", basename)
		# print basename
		if(length(EXCLUDE_PATTERN) && ( match($7, EXCLUDE_PATTERN) || match(basename, EXCLUDE_PATTERN) ))
		{
			exclude++
			print excludeHead"\t"sourcefile
		}
		else
		{
			valid++
			#gsub(DEST_DIR_PATTERN,"{D:}/",$7)
			#destfile=$7
			#print validHead"\t"sourcefile"\t\t\t ==> "destfile
			print validHead"\t"sourcefile
		}
	}
	else
	{
		invalid++
		print invalidHead"\t"sourcefile""
	}

}
END{
	#print "\n\tTotal:" valid+inval+exclude " Valid" validHead ":" valid " Invalid" invalidHead ":" invalid " Exclude" excludeHead ":" exclude "\n"
}
