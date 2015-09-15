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
	UNPASS2WAY		=	0;
	PASS2WAY		=	0;
	UNPASS3WAY		=	0;
	WAITING2_FILES	=	0;
	WAITING3_FILES	=	0;
	HAVE_FURDER		=	0;
	FORCE_REDO_LINE	=	0;
	
	# awk -f suggest-redo-list.awk FORCE_PATTERN="00822.." ./output/month_redo_output_201508.20150914163440
}

function dumpOneResult(){
	if (WAITING_FILES_FLAG || UNPASS_FLAG || NEW_COMING_FLAG || FORCE_REDO_FALG){
	
		if(UNPASS_FLAG || FORCE_REDO_FALG) {
			sub(/\|-\|/,"|R|", CURRENT_RESULT); 
		}
	
		WAITING_FILES_FLAG	= 0;
		NEW_COMING_FLAG		= 0;
		UNPASS_FLAG			= 0;
		FORCE_REDO_FALG		= 0;
		
		printf("%s\n",CURRENT_RESULT);
		
		if(A_FILE_ROW) printf("%s\n",A_FILE_ROW); 
		if(B_FILE_ROW) printf("%s\n",B_FILE_ROW); 
		if(C_FILE_ROW) printf("%s\n",C_FILE_ROW); 
		# if(L_FILE_ROW) printf("%s\n",L_FILE_ROW); 
		# if(R_FILE_ROW) printf("%s\n",R_FILE_ROW); 
		
		
		printf("%s",SHOW_LINES);
		
		
	}

}


/\|M[23]\|$/ { 
	
	dumpOneResult();
	
	split($2,__FLAGS,"");
	
	HAVE_RESULT_FLAG	=	__FLAGS[1] == "%" ? 1 : 0;
	RESUL_PASS_FLAG		=	__FLAGS[2] == "%" ? 1 : 0;
	HAVE_FURTER_FLAG	=	__FLAGS[3] == "%" ? 1 : 0;
	BIZ_PRIVINCE_CODE	=	$3;

	CURRENT_RESULT 	= $0;
	M3_FLAG			=	match(CURRENT_RESULT, /\|M3\|$/);
	CURRENT_COMPARE_TYPE = $(NF-3)
	SHOW_LINES = "";
	A_FILE_ROW = "";
	B_FILE_ROW = "";
	C_FILE_ROW = "";
	# L_FILE_ROW = "";
	# R_FILE_ROW = "";
	
	ALL_RESULT++;
	
	if(HAVE_RESULT_FLAG && RESUL_PASS_FLAG) { 
		if(M3_FLAG) 
			PASS3WAY++;
		else 
			PASS2WAY++;
			
		if (length(FORCE_PATTERN) && match(BIZ_PRIVINCE_CODE, FORCE_PATTERN)) {
			FORCE_REDO_FALG=1;
			FORCE_REDO_LINE++;
		}
	} else if (HAVE_RESULT_FLAG && ! RESUL_PASS_FLAG) {
		if(M3_FLAG) 
			UNPASS3WAY++;
		else 
			UNPASS2WAY++;
	} else if (! HAVE_RESULT_FLAG && ! RESUL_PASS_FLAG) {
		
		if(M3_FLAG) 
			WAITING3_FILES++;
		else 
			WAITING2_FILES++;
	}
	
	
	if(!HAVE_RESULT_FLAG){
		WAITING_FILES_FLAG	= 	1;
	} else if(!RESUL_PASS_FLAG){
		UNPASS_FLAG 	=	1;
	}
}

/\|MI\|$/{
	ONEROW	=	$0;
	STATE_SYMBLE = $2;
	FILE_NAME	=	$4;
	if(UNPASS_FLAG || RESUL_PASS_FLAG || FORCE_REDO_FALG){
		if(STATE_SYMBLE == "AAA"){
			# TODO 判断 taskman 是否重启过，如果重启时间在结果时间之前则需呀全部拷贝进行重跑 
			A_FILE_ROW = ONEROW;
			next;
		} else if(STATE_SYMBLE == "BBB"){
			if(UNPASS_FLAG) sub(/ \|/,"R|", ONEROW); 
			else if (FORCE_REDO_FALG)  sub(/ \|/,"F|", ONEROW); 
			B_FILE_ROW = ONEROW;
			next;
		} else if(STATE_SYMBLE == "CCC"){
			C_FILE_ROW = ONEROW;
			next;
		} else if(STATE_SYMBLE == "LLL"){
			L_FILE_ROW	= ONEROW;
			next;
		} else if(STATE_SYMBLE == "RRR"){
			R_FILE_ROW = ONEROW;
			next;
		} else if(STATE_SYMBLE == " + "){
		
		}
	
	} else if(WAITING_FILES_FLAG){
		if(STATE_SYMBLE == " - "){
			_str=CURRENT_COMPARE_TYPE
			gsub(/_/,".*", _str); 
			# print _str
			split(_str,_ARR, "+");
			TYPE	=	"#";
			# print FILE_NAME,_ARR[1],_ARR[2],_ARR[3],match(FILE_NAME,_ARR[1])
			if(match(FILE_NAME,_ARR[1])){
				TYPE=  M3_FLAG ? "A" : "L";
				sub(/\| - \|/,"U| "TYPE" |", ONEROW);
				A_FILE_ROW = ONEROW;
				next;	
			} else if(match(FILE_NAME,_ARR[2])){
				TYPE=  M3_FLAG ? "B" : "R";
				sub(/\| - \|/,"U| "TYPE" |", ONEROW); 
				B_FILE_ROW = ONEROW;
				next
			} else if(match(FILE_NAME,_ARR[3]) && M3_FLAG){
				TYPE="C";
				sub(/\| - \|/,"U| "TYPE" |", ONEROW); 
				C_FILE_ROW = ONEROW;
				next;
			} 
		} 
	}
	


	if(STATE_SYMBLE == " + "){
		
		_str=CURRENT_COMPARE_TYPE
		gsub(/_/,".*", _str); 
		# print CURRENT_COMPARE_TYPE
		split(_str,_ARR, "+");
		TYPE	=	"#";
		# print _ARR[1],_ARR[2],_ARR[3]
		if(match(ONEROW,_ARR[1]) || match(ONEROW,_ARR[2]) ||
		(M3_FLAG && match(ONEROW,_ARR[3]))){
			
			HAVE_FURDER++;
			NEW_COMING_FLAG	= 1;
			sub(/ \|/,"N|", ONEROW);
		} 
	}
	
	SHOW_LINES	=	SHOW_LINES""ONEROW"\n";

}

END{
	FORMAT_LINE="\n\n\n  ***  总结果数： %d\n";
	FORMAT_LINE=FORMAT_LINE"  ***  强制重跑: %d  有新文件未处理： %d\n";
	FORMAT_LINE=FORMAT_LINE"  ***  双方通过：%d  双方未通过：%d   双方文件未到齐： %d \n";
	FORMAT_LINE=FORMAT_LINE"  ***  三方通过：%d  三方未通过：%d   三方文件未到齐： %d \n";

	# FORMAT_LINE=FORMAT_LINE"# 总结果数： %d\n";
	
	

	printf(FORMAT_LINE,\
	ALL_RESULT,
	FORCE_REDO_LINE, HAVE_FURDER,
	PASS2WAY,UNPASS2WAY,WAITING2_FILES,
	PASS3WAY,UNPASS3WAY,WAITING3_FILES);
}