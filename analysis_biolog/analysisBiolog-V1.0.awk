#!/usr/bin/awk -f

BEGIN { 

	if(length(FINGER_BMP_FILE) == 0)
	{
		FINGER_BMP_FILE="/mnt/ramdisk/finger.bmp"
	}
	
	if(length(SAVE_BMP_FILE_DIR) == 0)
	{
		SAVE_BMP_FILE_DIR="/mnt/mtdblock/finger/"
	}

	if(length(RAW_BIO_LOG_FILE) == 0)
	{
		RAW_BIO_LOG_FILE="/mnt/mtdblock/rawbio.log"
	}
	
	times=0

	#if(system("mkdir "  SAVE_BMP_FILE_DIR  "-p") != 0)
	#{
	#	print "Error..."
		
	#}

	printf ("# FINGER_BMP_FILE:%s\n ", FINGER_BMP_FILE)
	printf ("# SAVE_BMP_FILE_DIR:%s\n ", SAVE_BMP_FILE_DIR)
	printf ("# RAW_BIO_LOG_FILE:%s\n ", RAW_BIO_LOG_FILE)
}

## 加载用户数据
/^[0-9]+\|[0-9]+\|/{
	ID=$0
	sub(/\|.*/,"",ID)
	
	sub(/[^|]*\|/,"",$0)
	PIN=$0
	sub(/\|.*/,"",PIN)

	Name=$0
	sub(/.*\|/,"",Name)
	
	ID2PIN[ID]=PIN

	if(length(Name))
	{
		ID2NAME[ID]=Name	
	}
	else
	{
		ID2NAME[ID]=PIN	
	}
	
	next
	#print  ID2PIN[ID] "--" ID2NAME[ID]
}

{
	print >RAW_BIO_LOG_FILE
}

#保存指纹图片相关逻辑
/src:main dst:biometric cmd:3008 subcmd:1/{
	
	
#	next
	#printf ( "cp %s %s%04d.bmp \n", FINGER_BMP_FILE,SAVE_BMP_FILE_DIR,times); 
	cmd=sprintf("cp %s %s%04d.bmp",FINGER_BMP_FILE, SAVE_BMP_FILE_DIR, times);
	if(system(cmd) != 0)
	{
			print "Error..."
	}	

}

/biometric Version:/ {

	if(times>0 && passCnt>0)
	{

		
		printf ("\n\t*** Total=%d  Pass=%d PassRate=%.2f%% AverageQuality=%d AveragePassScore=%d  AverageVerifyTime=%d(ms) ***\n\n", \
	times+1, passCnt, (passCnt*100)/times, allQuality/times, allScore/passCnt, allVerifyTime/times )
	
		printf ("################################################################################\n")
	}

	Version=$0
	sub(/.*biometric Version:/, "", Version);

	printf("\n\t*** Version:%s ***\n\n", Version)

	ExtractBiokeyFPTime=0
	IdentifyBiokeyFPTime=0
	UID=0
	FID=0
	Valid=0
	Quality=0
	Score=0
	Status=0
	CurTime=""


	times=0
	allVerifyTime=0
	allQuality=0
	allScore=0
	passCnt=0

	next
}

## 解析时间与提取模板的时间
/ExtractBiokeyFP/{
	CurTime=$1
	sub(/biometric:/, "", CurTime);
	sub(/T/, " ", CurTime);

	ExtractBiokeyFPTime=$0
	sub(/.*time:/, "", ExtractBiokeyFPTime);
	#print CurTime " " ExtractBiokeyFPTime
	next
}

## 提取验证耗时
/IdentifyBiokeyFP over/{

	IdentifyBiokeyFPTime=$0
	sub(/.*over time:/, "", IdentifyBiokeyFPTime);
	#print IdentifyBiokeyFPTime
	next
}

## userID:2, fingerID:6, valid:1, fpQuality:69, score:100, reply status:200

/userID.*reply status/{

	

	UID=$6
	gsub(/[^0-9-]/,"",UID)

	FID=$7
	gsub(/[^0-9]/,"",FID)

	Valid=$8
	gsub(/[^0-9]/,"",Valid)

	Quality=$9
	gsub(/[^0-9]/,"",Quality)

	Score=$10
	gsub(/[^0-9]/,"",Score)

	oneVerifyTime=IdentifyBiokeyFPTime+ExtractBiokeyFPTime

	if(times%15==0)
	{	
		printf("\n\t|********Verify Time*******|*Q*|*S*|**Time**|*Line*|**** <F>PIN(Name) ****\n", times, CurTime, UID, FID, Quality, Score, oneVerifyTime)
		
	}

	
	#  UID "-" FID "-"  Quality "-" Score
	if(UID > 0)
	{
		printf("\t|%4d:%s|%3d|%3d|%4d(ms)|%6d|<%d>%5s(%s)\n", ++times, CurTime, Quality, Score, oneVerifyTime, NR,  FID, ID2PIN[UID], ID2NAME[UID])
	}
	else
	{
		printf("\t|%4d:%s|%3d|%3d|%4d(ms)|%6d|%s\n", ++times, CurTime, Quality, Score, oneVerifyTime, NR , "   ####  ")
	}
	

	if(UID>0){
		passCnt++;
		allScore+=Score
	}	
	#times++
	allQuality+=Quality
	allVerifyTime+=oneVerifyTime
	next 
}

END{
	if(times>0 && passCnt>0)
	{
		
		printf ("\n\t*** Total=%d  Pass=%d PassRate=%.2f%% AverageQuality=%d AveragePassScore=%d  AverageVerifyTime=%d(ms) ***\n\n", \
		times+1, passCnt, (passCnt*100)/times, allQuality/times, allScore/passCnt, allVerifyTime/times )
	}
}

