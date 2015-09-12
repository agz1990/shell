#!/usr/bin/awk	-f

########################################################################
# Author      : jigc 
# Script Name : suggest-redo-list.awk
# Date        : 2015-9-12
# Description : 
# Version     : V1.0
# Usage       : 
# Log:
#
########################################################################

BEGIN{
	FS="|"
	ALL_RESULT		=	0;
	PASS3WAY		=	0;
	UNPASS3WAY		=	0;
	WAITING_FILES	=	0;
	HAVE_FURDER		=	0;
	
}

/\|[23]WAY\|$/ { 
	if(WAITING_FILES_FLAG || UNPASS3WAY_FLAG || NEW_COMING_FLAG){
		WAITING_FILES_FLAG	= 0;
		NEW_COMING_FLAG		= 0;
		UNPASS3WAY_FLAG		= 0;
		
		printf("%s",SHOW_LINES);
		
	}
	
	CURRENT_RESULT = $0;
	CURRENT_COMPARE_TYPE = $(NF-2)
	SHOW_LINES = $0"\n";
	
	ALL_RESULT++;
	
	if(match($2,/%%/)) { PASS3WAY++;}
	else if (match($2,/%-/)) { UNPASS3WAY++;}
	else if (match($2,/--/)) { WAITING_FILES++;}
	
	
	if(match($2,"^--[-%]")){
		WAITING_FILES_FLAG	= 	1;
	} else if(match($2,"^%-[-%]")){
		UNPASS3WAY_FLAG 	=	1;
	} 
}

/\|ICF\|$/{
	ONEROW	=	$0;
	if(UNPASS3WAY_FLAG){
		if(match(ONEROW,/#AAA#.*\|ICF\|$/)){
			# TODO 判断 taskman 是否重启过，如果重启时间在结果时间之前则需呀全部拷贝进行重跑 
			
		} else if(match(ONEROW,/#BBB#.*\|ICF\|$/)){
			sub(/ \|/,"*|", ONEROW); 
		} else if(match(ONEROW,/#CCC#.*\|ICF\|$/)){
		
		}  else if(match(ONEROW,/# + #.*\|ICF\|$/)){
		
		}
	
	} else if(WAITING_FILES_FLAG){
		if(match(ONEROW,/# - #.*\|ICF\|$/)){
			_str=CURRENT_COMPARE_TYPE
			gsub(/_/,".*", _str); 
			# print _str
			split(_str,_ARR, "+");
			TYPE	=	"#";
			# print _ARR[1],_ARR[2],_ARR[3]
				 if(match(ONEROW,_ARR[1])){TYPE="A"}
			else if(match(ONEROW,_ARR[2])){TYPE="B"}
			else if(match(ONEROW,_ARR[3])){TYPE="C"}

			
			sub(/ \|# - #/,"+|# "TYPE" #", ONEROW); 
		} 
	}

	if(match(ONEROW,/# \+ #/)){
		HAVE_FURDER++;
		NEW_COMING_FLAG	= 1;
		sub(/ \|/,"%|", ONEROW);
	}
	SHOW_LINES	=	SHOW_LINES""ONEROW"\n";

}

END{	
	printf("*** 总结果数： %d   三方通过： %d   三方未通过： %d   三方文件未到齐： %d   三方有新文件未处理： %d  ***\n",\
	ALL_RESULT,PASS3WAY,UNPASS3WAY,WAITING_FILES,HAVE_FURDER);
}