#!/usr/bin/awk	-f

########################################################################
# Author      : jigc 
# Script Name : merge-result-incoming-table.awk
# Date        : 2015-9-12
# Description : ��˫���������������incoming��ϲ�
# Version     : V1.0
# Usage       : 
# Log:
#
########################################################################

BEGIN{
	FS="[[:space:]]+"
	INCOMING_CNT 			= 	0;
	INCOMING_VALID_CNT 		=	0;
	INCOMING_TOTAL_SIZE		=	0;
	INCOMING_VALID_SIZE		=	0;
	
	
	
	# FOR RESULT3_ARRAY
	__RET3_BIZ_PRIVINCE_CODE		=	2;
	__RET3_A_FILE_NAME				=	3;
	__RET3_B_FILE_NAME				=	4;
	__RET3_C_FILE_NAME				=	5;
	__RET3_COMPARE_TYPE				=	6;
	__RET3_CREATE_TIME				=	7;
	__RET3_COMFORM_RATIO			=	8;
	__RET3_CREATE_TIME_STAMP		=	9;
	__RET3_N1						=	10;
	__RET3_N2						=	11;
	__RET3_N3						=	12;
	__RET3_N4						=	13;
	__RET3_N5						=	14;
	__RET3_N6						=	15;
	__RET3_N7						=	16;
	__RET3_A_REPEAT_RECORD			=	17;
	__RET3_B_REPEAT_RECORD			=	18;
	__RET3_C_REPEAT_RECORD			=	19;
	__RET3_A_RECORD_TOTAL			=   20;
	__RET3_B_RECORD_TOTAL			=   21;
	__RET3_C_RECORD_TOTAL			=   22;
	                                     
	
	# FOR MONTH_INCOMING
	__MICM_BIZ_PRIVINCE_CODE		=	2;			
	__MICM_FILE_NAME				=	3;
	__MICM_FILE_SIZE                =	4;
	__MICM_CKSUM_VALUE              =	5;
	__MICM_STATE                    =	6;
	__MICM_RESEND_NUM               =	7;
	__MICM_VALIDITY                 =	8;
	__MICM_INCOMING_TIME            =	9;
	__MICM_INCOMING_TIME_STAMP		=	10;
	
}


NF == 21 && $0 ~ /RESULT3$/ {
	
	# 0005100
	BIZ_PRIVINCE_CODE	=	$1;
	
	# FLAT_20150815010000_0005100.0002241498.gz
	A_FILE_NAME			=	$2;
	
	# BOSS_20150815010000_0005100.0002216201.gz
	B_FILE_NAME			=	$3;
	
	# VGOP_20150815010000_0005100.0002242968.gz
	C_FILE_NAME			=	$4;
	
	# �Ա����� FLAT_0005+BOSS_0005+VGOP_0005
	COMPARE_TYPE		=	$5;
	
	# ʱ���ַ��� 2015-08-25#19:11:00
	CREATE_TIME			=	$6;
	_timstr=CREATE_TIME;
	gsub(/[#:-]/," ", _timstr);
	CREATE_TIME_STAMP=mktime(_timstr);
	
	# ��ȷ��
	COMFORM_RATIO		=	$7;
	
	# N1~N7
	N1	=	$8;
	N2	=	$9;
	N3	=	$10;
	N4	=	$11;
	N5	=	$12
	N6	=	$13;
	N7	=	$14;
	
	# �ظ���¼��
	A_REPEAT_RECORD		=	$15;
	B_REPEAT_RECORD		=	$16;
	C_REPEAT_RECORD		=	$17;
	
	# �ļ���¼����
	A_RECORD_TOTAL		=	$18;
	B_RECORD_TOTAL		=	$19;
	C_RECORD_TOTAL		=	$20;
	
	
	_format="|%s|%41s|%41s|%41s|%s|%19s|%6.2f|%011s|%d|%d|%d|"
	RESULT3_ARRAY[BIZ_PRIVINCE_CODE]=sprintf(_format,\
	BIZ_PRIVINCE_CODE,\
	A_FILE_NAME,B_FILE_NAME,C_FILE_NAME,COMPARE_TYPE,\
	CREATE_TIME,COMFORM_RATIO,CREATE_TIME_STAMP,\
	N1"|"N2"|"N3"|"N4"|"N5"|"N6"|"N7,\
	A_REPEAT_RECORD"|"B_REPEAT_RECORD"|"C_REPEAT_RECORD,\
	A_RECORD_TOTAL"|"B_RECORD_TOTAL"|"C_RECORD_TOTAL);
	
	
	KEY_ORDER_ARRAY[RESULT3_CNT++] = BIZ_PRIVINCE_CODE;
	
	next;
	
}

NF == 9 && $0 ~ /MONTH_INCOMING$/ {
	BIZ_PRIVINCE_CODE	=	$1;
	FILE_NAME			=	$2;
	FILE_SIZE			=	$3;
	CKSUM_VALUE			=	$4;
	STATE				=	$5;
	RESEND_NUM			=	$6;
	VALIDITY			=	$7;
	INCOMING_TIME		=	$8;
	
	{ # ͨ��date ��������ַ����ٶ�̫��
		# _timstr=INCOMING_TIME
		# sub(/#/," ", _timstr);
		
		# getline INCOMING_TIME_STAMP < "date" #"date -d "_timstr" +%s"
		# "date -d \""_timstr"\" +%s" | getline INCOMING_TIME_STAMP;
		# close("date -d \""_timstr"\" +%s")
	}
	_timstr=INCOMING_TIME
	gsub(/[#:-]/," ", _timstr);
	INCOMING_TIME_STAMP=mktime(_timstr)
	
	CNT_KEY=BIZ_PRIVINCE_CODE"+CNT";
	if(MONTH_INCOMING[CNT_KEY] <= 0){
		MONTH_INCOMING[CNT_KEY] = 1;
	}
	
	
	INDEX_KEY=BIZ_PRIVINCE_CODE"+"MONTH_INCOMING[CNT_KEY]++;
	MONTH_INCOMING[INDEX_KEY]=sprintf("|%s|%41s|%11d|%11s|%2s|%2s|%2s|%19s|%012s|",\
	BIZ_PRIVINCE_CODE,FILE_NAME,FILE_SIZE,CKSUM_VALUE,STATE,RESEND_NUM,VALIDITY,INCOMING_TIME,INCOMING_TIME_STAMP);
	
	next;
}

END{

	for( _index_number = 0; _index_number < RESULT3_CNT; _index_number ++){
		
		A_FLAG	=	"---";
		B_FLAG	=	"---";
		C_FLAG	=	"---";
		
		_biz_privince_code 	=	KEY_ORDER_ARRAY[_index_number];
		
		split(RESULT3_ARRAY[_biz_privince_code], _RET,"|");
		CNT_KEY=_biz_privince_code"+CNT";
		
	
		MUL_LINE	=	"";
		HAVE_FURDER	=	0;
		for(i = 1; i < MONTH_INCOMING[CNT_KEY]; i++){

			
			INDEX_KEY	=	_biz_privince_code"+"i;
			split(MONTH_INCOMING[INDEX_KEY], _ONE_FILE_ROW,"|");
			LINE		=	MONTH_INCOMING[INDEX_KEY];
			FILE_NAME	=	_ONE_FILE_ROW[__MICM_FILE_NAME];
			STATE		= 	_ONE_FILE_ROW[__MICM_STATE];
			
						
			INCOMING_CNT ++;
			INCOMING_TOTAL_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE];
			if(_ONE_FILE_ROW[__MICM_INCOMING_TIME_STAMP] >= _RET[__RET3_CREATE_TIME_STAMP]){
				HAVE_FURDER		=	1;
				STATE_SYMBLE	=	"# + #"
			} else if(STATE == 4 || STATE == 6){
				STATE_SYMBLE	=	"# ! #";
			} else if(FILE_NAME == _RET[__RET3_A_FILE_NAME]){
				STATE_SYMBLE	=	"#AAA#";
				A_FLAG			=	"AAA";
				INCOMING_VALID_CNT ++;
				INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]
			} else if(FILE_NAME == _RET[__RET3_B_FILE_NAME]) {
				STATE_SYMBLE	=	"#BBB#";
				B_FLAG			=	"BBB";
				INCOMING_VALID_CNT ++;
				INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]				
			} else if(FILE_NAME == _RET[__RET3_C_FILE_NAME]) {
				STATE_SYMBLE	=	"#CCC#";
				C_FLAG			=	"CCC";
				INCOMING_VALID_CNT ++;
				INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]					
			} else {
				STATE_SYMBLE	=	"# - #";
			}
			
			FILE_DETAIL_OUTPUT_FORMAT="|%s%07s|%41s|%1d|%8.2f(M)|%12s|%19s|ICF|\n";
			LINE=sprintf(FILE_DETAIL_OUTPUT_FORMAT, \
			STATE_SYMBLE,\
			_ONE_FILE_ROW[__MICM_BIZ_PRIVINCE_CODE],\
			_ONE_FILE_ROW[__MICM_FILE_NAME],\
			_ONE_FILE_ROW[__MICM_STATE],\
			_ONE_FILE_ROW[__MICM_FILE_SIZE]/1024/1024,\
			_ONE_FILE_ROW[__MICM_CKSUM_VALUE],\
			_ONE_FILE_ROW[__MICM_INCOMING_TIME])
			
			MUL_LINE	=	MUL_LINE"       "LINE;
		}
		
		RESULT3_OUTPUT_FORMAT="|%s|%s|%6.2f%%|%3s|%3s|%3s|%19s|%s|3WAY|\n";
		if(A_FLAG == "AAA" && B_FLAG == "BBB" && C_FLAG == "CCC"){
			VALID_RESULT	=	"%"
		}else{
			HAVE_FURDER		=	0; # �����ļ�δ���룬û��δ�����ļ��ĸ���
			VALID_RESULT	=	"-"
		}
		
		if(VALID_RESULT == "%" && _RET[__RET3_COMFORM_RATIO] >= 90){
			VALID_RATIO 	=	"%"
		} else {
			VALID_RATIO 	=	"-"
		}
		
		if(HAVE_FURDER){
			FURDER_RESULT	=	"-";
		} else {
			FURDER_RESULT	=	"%";
		}
		
		
		
		printf(RESULT3_OUTPUT_FORMAT, \
		VALID_RESULT""VALID_RATIO""FURDER_RESULT,\
		_RET[__RET3_BIZ_PRIVINCE_CODE],_RET[__RET3_COMFORM_RATIO],\
		A_FLAG,B_FLAG,C_FLAG,\
		_RET[__RET3_CREATE_TIME],\
		_RET[__RET3_COMPARE_TYPE]);
		sort MUL_LINE
		print MUL_LINE # | "sort -t '|' -k 7" | 
	}

	printf ("\n *** INCOMING_CNT: %d   INCOMING_VALID_CNT: %d  INCOMING_TOTAL_SIZE: %6.2f (G)  INCOMING_VALID_SIZE: %6.2f (G)  ***\n\n",
	INCOMING_CNT,INCOMING_VALID_CNT, INCOMING_TOTAL_SIZE/1024/1024/1024,INCOMING_VALID_SIZE/1024/1024/1024)
	
}