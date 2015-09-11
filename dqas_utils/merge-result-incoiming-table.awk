#!/usr/bin/awk	-f

BEIN{
	FS="[:space:]+"
	
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
	
	RESULT3_ARRAY[BIZ_PRIVINCE_CODE]=sprintf("|%s|%41s|%41s|%41s|%19s|%6.2f|%10s|",\
	BIZ_PRIVINCE_CODE,$2,$3,$4,$6,$7,C_RECORD_TOTAL);
	
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
	
	CNT_KEY=BIZ_PRIVINCE_CODE"+CNT";
	if(MONTH_INCOMING[CNT_KEY] <= 0){
		MONTH_INCOMING[CNT_KEY] = 1;
	}
	# print "#" BIZ_PRIVINCE_CODE"#"CNT_KEY"="MONTH_INCOMING[CNT_KEY] "#" $2;
	
	INDEX_KEY=BIZ_PRIVINCE_CODE"+"MONTH_INCOMING[CNT_KEY]++;
	MONTH_INCOMING[INDEX_KEY]=sprintf("|%s|%41s|%11d|%11s|%2s|%2s|%2s|%19s|",\
	BIZ_PRIVINCE_CODE,FILE_NAME,FILE_SIZE,CKSUM_VALUE,STATE,RESEND_NUM,VALIDITY,INCOMING_TIME);
}

END{
	count = 0;
	for( _biz_privince_code in RESULT3_ARRAY){
		print RESULT3_ARRAY[_biz_privince_code];
		CNT_KEY=_biz_privince_code"+CNT";
		for(i = 1; i < MONTH_INCOMING[CNT_KEY]; i++){
			
			if(i == 1){
				print "\t\\_"MONTH_INCOMING[INDEX_KEY];
			}
			else{
				print "\t  "MONTH_INCOMING[INDEX_KEY];
			}
			
			INDEX_KEY=_biz_privince_code"+"i;
			# print CNT_KEY"\t"INDEX_KEY"\t"MONTH_INCOMING[INDEX_KEY
		}
		print "\n";
		# if(++count>20){
			# exit
		# }
	}
	# printf ("\n *** File Count: %d    Total Size: %f G ***\n\n",fcnt, all/1024/1024/1024)
}