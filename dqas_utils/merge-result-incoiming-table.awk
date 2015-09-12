#!/usr/bin/awk	-f

BEIN{
	FS="[:space:]+"
	
	INCOMING_CNT 			= 	0;
	INCOMING_VALID_CNT 		=	0;
	INCOMING_TOTAL_SIZE		=	0;
	INCOMING_VALID_SIZE		=	0;
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
	
	# 对比类型 FLAT_0005+BOSS_0005+VGOP_0005
	COMPARE_TYPE		=	$5;
	
	# 时间字符串 2015-08-25#19:11:00
	CREATE_TIME			=	$6;
	_timstr=CREATE_TIME;
	gsub(/[#:-]/," ", _timstr);
	CREATE_TIME_STAMP=mktime(_timstr);
	
	# 正确率
	COMFORM_RATIO		=	$7;
	
	# N1~N7
	N1	=	$8;
	N2	=	$9;
	N3	=	$10;
	N4	=	$11;
	N5	=	$12
	N6	=	$13;
	N7	=	$14;
	
	# 重复记录数
	A_REPEAT_RECORD		=	$15;
	B_REPEAT_RECORD		=	$16;
	C_REPEAT_RECORD		=	$17;
	
	# 文件记录总数
	A_RECORD_TOTAL		=	$18;
	B_RECORD_TOTAL		=	$19;
	C_RECORD_TOTAL		=	$20;
	
	
	# printf("|%s|%41s|%41s|%41s|%19s|%6.2f|%10s|\n",\
	# BIZ_PRIVINCE_CODE,$2,$3,$4,$6,$7,C_RECORD_TOTAL);
	
	RESULT3_ARRAY[BIZ_PRIVINCE_CODE]=sprintf("|%s|%41s|%41s|%41s|%19s|%6.2f|%011s|",\
	BIZ_PRIVINCE_CODE,A_FILE_NAME,B_FILE_NAME,C_FILE_NAME,CREATE_TIME,COMFORM_RATIO,CREATE_TIME_STAMP);
	
	
	KEY_ORDER_ARRAY[RESULT3_CNT++] = BIZ_PRIVINCE_CODE;
	
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
	
	{ # 通过date 命令解析字符串速度太慢
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

}

END{
	# FOR RESULT3_ARRAY
	__RET3_BIZ_PRIVINCE_CODE		=	2;
	__RET3_A_FILE_NAME				=	3;
	__RET3_B_FILE_NAME				=	4;
	__RET3_C_FILE_NAME				=	5;
	__RET3_COMPARE_TYPE				=	6;
	__RET3_CREATE_TIME				=	7;
	__RET3_CREATE_TIME_STAMP		=	8;
	__RET3_COMFORM_RATIO			=	9;
	
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
	
	
	for( _index_number = 0; _index_number < RESULT3_CNT; _index_number ++){
	
		_biz_privince_code 	=	KEY_ORDER_ARRAY[_index_number];
		RET_LINE			=	RESULT3_ARRAY[_biz_privince_code];
		
		
		sub(/\|[^|]*\|$/,"|", RET_LINE);
		print RET_LINE;
		split(RESULT3_ARRAY[_biz_privince_code], _RET,"|");
		CNT_KEY=_biz_privince_code"+CNT";
		
		DETAIL_MSG=""
		for(i = 1; i < MONTH_INCOMING[CNT_KEY]; i++){

			
			INDEX_KEY	=	_biz_privince_code"+"i;
			split(MONTH_INCOMING[INDEX_KEY], _ONE_FILE_ROW,"|");
			LINE		=	MONTH_INCOMING[INDEX_KEY];
			FILE_NAME	=	_ONE_FILE_ROW[__MICM_FILE_NAME];
			STATE		= 	_ONE_FILE_ROW[__MICM_STATE];
						
			INCOMING_CNT ++;
			INCOMING_TOTAL_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE];
			
			if(STATE == 4 || STATE == 6){
				# print STATE;
				sub(/\|/,"|#X#", LINE);
				
			} else if(FILE_NAME == _RET[__RET3_A_FILE_NAME]){
				sub(/\|/,"|#A#", LINE);
				INCOMING_VALID_CNT ++;
				INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]
			} else if(FILE_NAME == _RET[__RET3_B_FILE_NAME]) {
				sub(/\|/,"|#B#", LINE);
				INCOMING_VALID_CNT ++;
				INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]				
			} else if(FILE_NAME == _RET[__RET3_C_FILE_NAME]) {
				sub(/\|/,"|#C#", LINE);
				INCOMING_VALID_CNT ++;
				INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]					
			} else {
				sub(/\|/,"|#-#", LINE);
			}
			
			print "\t  "LINE;
		}
		
		print "\n";
	
	}

	printf ("\n *** INCOMING_CNT: %d   INCOMING_VALID_CNT: %d  INCOMING_TOTAL_SIZE: %6.2f (G)  INCOMING_VALID_SIZE: %6.2f (G)  ***\n\n",
	INCOMING_CNT,INCOMING_VALID_CNT, INCOMING_TOTAL_SIZE/1024/1024/1024,INCOMING_VALID_SIZE/1024/1024/1024)
}