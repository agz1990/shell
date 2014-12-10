#!/usr/bin/awk -f

BEGIN { 
	times=0
}

/biometric Version:/ {

	if(times>0 && passCnt>0)
	{

		
		printf ("\n\t*** Total=%d  Pass=%d PassRate=%.2f%% AverageQuality=%d AveragePassScore=%d  AverageVerifyTime=%d(ms) ***\n\n", \
	times, passCnt, (passCnt*100)/times, allQuality/times, allScore/passCnt, allVerifyTime/times )
	
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

	if(UID < 0)
	{
		UID=" ## "
	}

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
		printf("\n\t|********Verify Time*******|**ID(F)|*Q*|*S*|**Time**|*Line*|\n", times, CurTime, UID, FID, Quality, Score, oneVerifyTime)
		
	}

	
	#  UID "-" FID "-"  Quality "-" Score
	printf("\t|%4d:%s|%4s(%d)|%3d|%3d|%4d(ms)|%6d|\n", ++times, CurTime, UID, FID,Quality, Score, oneVerifyTime, NR)

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
		times, passCnt, (passCnt*100)/times, allQuality/times, allScore/passCnt, allVerifyTime/times )
	}
}

