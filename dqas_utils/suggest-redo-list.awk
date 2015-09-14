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
	FORCE_PATTERN	=	"";
	ALL_RESULT		=	0;
	PASS3WAY		=	0;
	UNPASS3WAY		=	0;
	WAITING_FILES	=	0;
	HAVE_FURDER		=	0;
	FORCE_REDO_LINE	=	0;
	# awk -f suggest-redo-list.awk FORCE_PATTERN="00822.." ./output/month_redo_output_201508.20150914163440
}

/\|M[23]\|$/ { 
	if(WAITING_FILES_FLAG || UNPASS3WAY_FLAG || NEW_COMING_FLAG || FORCE_REDO_FALG){
		WAITING_FILES_FLAG	= 0;
		NEW_COMING_FLAG		= 0;
		UNPASS3WAY_FLAG		= 0;
		FORCE_REDO_FALG		= 0;
		
		printf("%s\n",CURRENT_RESULT);
		
		if(A_FILE_ROW) printf("%s\n",A_FILE_ROW); 
		if(B_FILE_ROW) printf("%s\n",B_FILE_ROW); 
		if(C_FILE_ROW) printf("%s\n",C_FILE_ROW); 
		
		
		printf("%s",SHOW_LINES);
		
	}
	HAVE_RESULT_FLAG	=	$2 == "%" ? 1 : 0;
	RESULT3_PASS_FLAG	=	$3 == "%" ? 1 : 0;
	HAVE_FURTER_FLAG	=	$4 == "%" ? 1 : 0;
	BIZ_PRIVINCE_CODE	=	$5;
	
	
	CURRENT_RESULT = $0;
	CURRENT_COMPARE_TYPE = $(NF-2)
	SHOW_LINES = "";
	A_FILE_ROW = "";
	B_FILE_ROW = "";
	C_FILE_ROW = "";
	
	ALL_RESULT++;
	
	if(HAVE_RESULT_FLAG && RESULT3_PASS_FLAG) { 
		PASS3WAY++;
		if (length(FORCE_PATTERN) && match(BIZ_PRIVINCE_CODE, FORCE_PATTERN)) {
			FORCE_REDO_FALG=1;
			FORCE_REDO_LINE++;
		}
	} else if (HAVE_RESULT_FLAG && ! RESULT3_PASS_FLAG) {
		UNPASS3WAY++;
	}
	else if (! HAVE_RESULT_FLAG && ! RESULT3_PASS_FLAG) {
		WAITING_FILES++;
	}
	
	
	if(!HAVE_RESULT_FLAG){
		WAITING_FILES_FLAG	= 	1;
	} else if(!RESULT3_PASS_FLAG){
		UNPASS3WAY_FLAG 	=	1;
	}
}

/\|MI\|$/{
	ONEROW	=	$0;
	STATE_SYMBLE = $2;
	if(UNPASS3WAY_FLAG || RESULT3_PASS_FLAG || FORCE_REDO_FALG){
		if(STATE_SYMBLE == "AAA"){
			# TODO 判断 taskman 是否重启过，如果重启时间在结果时间之前则需呀全部拷贝进行重跑 
			A_FILE_ROW = ONEROW;
			next;
		} else if(STATE_SYMBLE == "BBB"){
			if(UNPASS3WAY_FLAG) sub(/ \|/,"R|", ONEROW); 
			else if (FORCE_REDO_FALG)  sub(/ \|/,"F|", ONEROW); 
			B_FILE_ROW = ONEROW;
			next;
		} else if(STATE_SYMBLE == "CCC"){
			C_FILE_ROW = ONEROW;
			next;
		}  else if(STATE_SYMBLE == " + "){
		
		}
	
	} else if(WAITING_FILES_FLAG){
		if(STATE_SYMBLE == " - "){
			_str=CURRENT_COMPARE_TYPE
			gsub(/_/,".*", _str); 
			# print _str
			split(_str,_ARR, "+");
			TYPE	=	"#";
			# print _ARR[1],_ARR[2],_ARR[3]
			if(match(ONEROW,_ARR[1])){
				TYPE="A";
				A_FILE_ROW = ONEROW;
				sub(/ \| - \|/,"U| "TYPE" |", ONEROW); 
				next;	
			} else if(match(ONEROW,_ARR[2])){
				TYPE="B"
				B_FILE_ROW = ONEROW;
				sub(/ \| - \|/,"U| "TYPE" |", ONEROW); 
				next;	
			}else if(match(ONEROW,_ARR[3])){
				TYPE="C";
				B_FILE_ROW = ONEROW;
				sub(/ \| - \|/,"U| "TYPE" |", ONEROW); 
				next;		
			}
		} 
	}
	


	if(STATE_SYMBLE == " + "){
		HAVE_FURDER++;
		NEW_COMING_FLAG	= 1;
		sub(/ \|/,"N|", ONEROW);
	}
	
	SHOW_LINES	=	SHOW_LINES""ONEROW"\n";

}

END{	
	printf("*** 总结果数： %d   三方通过： %d   三方未通过： %d   三方文件未到齐： %d   三方有新文件未处理： %d  强制重跑: %d ***\n",\
	ALL_RESULT,PASS3WAY,UNPASS3WAY,WAITING_FILES,HAVE_FURDER,FORCE_REDO_LINE);
}