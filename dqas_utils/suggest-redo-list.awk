#!/usr/bin/awk    -f

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
    FORCE_PATTERN    =   "";
    ALL_RESULT       =   0;
    PASS3WAY         =   0;
    UNPASS2WAY       =   0;
    PASS2WAY         =   0;
    UNPASS3WAY       =   0;
    CHECK_ERROR2_CNT =   0;  # 结果校验错误计数器
    CHECK_ERROR3_CNT =   0;
    WAITING2_FILES   =   0;
    WAITING3_FILES   =   0;
    HAVE_FURDER      =   0;
    FORCE_REDO_LINE  =   0;
    
    INCOMING_CNT    =   0;
    USE_FOR_RESULT_CNT  =   0;  # 已经生成结果的文件
    UNMATCH_CNT         =   0;  # 未匹配成功的结果
    INCOMING_TOTAL_SIZE_M =   0;
    INCOMING_VALID_SIZE_M =   0;
    
    # awk -f suggest-redo-list.awk FORCE_PATTERN="00822.." ./output/month_redo_output_201508.20150914163440
}

function dumpOneResult(){
    if ( CURRENT_RESULT && \
        (!HAVE_RESULT_FLAG || \
         !RESUL_CHECK_SUCCESS_FLAG || \
         !RESUL_PASS_THRESHOLD_FLAG || \
         NEW_COMING_FLAG || \
         FORCE_REDO_FALG)){
    
        if(UNPASS_FLAG || FORCE_REDO_FALG) {
            sub(/\|-\|/,"|R|", CURRENT_RESULT); 
        }
    
        
        NEW_COMING_FLAG        = 0;
        FORCE_REDO_FALG        = 0;
        
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
    
    HAVE_RESULT_FLAG            =    __FLAGS[1] == "%" ? 1 : 0;
    RESUL_CHECK_SUCCESS_FLAG    =    __FLAGS[2] == "%" ? 1 : 0;
    RESUL_PASS_THRESHOLD_FLAG   =    __FLAGS[3] == "%" ? 1 : 0;
    HAVE_FURTER_FLAG            =    __FLAGS[4] == "%" ? 1 : 0;
    BIZ_PRIVINCE_CODE           =    $3;

    CURRENT_RESULT     = $0;
    M3_FLAG            =    match(CURRENT_RESULT, /\|M3\|$/);
    CURRENT_COMPARE_TYPE = $(NF-3)
    SHOW_LINES = "";
    A_FILE_ROW = "";
    B_FILE_ROW = "";
    C_FILE_ROW = "";
    # L_FILE_ROW = "";
    # R_FILE_ROW = "";
    
    ALL_RESULT++;
    if(HAVE_RESULT_FLAG){ # 比对出结果
        if(RESUL_CHECK_SUCCESS_FLAG){ # 比对结果有效
            if(RESUL_PASS_THRESHOLD_FLAG){ #通过率达标
                if(M3_FLAG) 
                    PASS3WAY++;
                else 
                    PASS2WAY++;
                    
                if (length(FORCE_PATTERN) && match(BIZ_PRIVINCE_CODE, FORCE_PATTERN)) {  # 标记强制执行
                    FORCE_REDO_FALG=1;
                    FORCE_REDO_LINE++;
                }
            }else{ # 结果通过率未达标
                
                if(M3_FLAG) 
                    UNPASS3WAY++;
                else 
                    UNPASS2WAY++;
            }
        
        
        } else { #结果校验出错
            if(M3_FLAG) 
                CHECK_ERROR3_CNT++;
            else 
                CHECK_ERROR2_CNT++;
           
        }
       
    } else {    # 还未得出结果
        if(M3_FLAG) 
            WAITING3_FILES++;
        else 
            WAITING2_FILES++;
    }

}

/\|MI\|$/{
    ONEROW    =    $0;
    STATE_SYMBLE = $2;
    FILE_NAME    =    $4;
    FILE_SIZE_M  =    $6;
    INCOMING_CNT ++;
    INCOMING_TOTAL_SIZE_M +=  FILE_SIZE_M;
    
    if(STATE_SYMBLE == "AAA" || STATE_SYMBLE == "BBB" || STATE_SYMBLE == "CCC" || \
       STATE_SYMBLE == "LLL"  || STATE_SYMBLE == "RRR" ){
        USE_FOR_RESULT_CNT  ++;
        INCOMING_VALID_SIZE_M += FILE_SIZE_M;
    }
  
    
    if(HAVE_RESULT_FLAG){
    
        if(!RESUL_CHECK_SUCCESS_FLAG){
            MARK_SYMBLE =   "E";
        } else if(!RESUL_PASS_THRESHOLD_FLAG){
            MARK_SYMBLE =   "R"
        } else if(FORCE_REDO_FALG) {
            MARK_SYMBLE =   "F"
        }
         
    
        if(STATE_SYMBLE == "AAA"){
            # TODO 判断 taskman 是否重启过，如果重启时间在结果时间之前则需呀全部拷贝进行重跑 
            A_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == "BBB"){
            sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
            B_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == "CCC"){
            C_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == "LLL"){
            L_FILE_ROW    = ONEROW;
            next;
        } else if(STATE_SYMBLE == "RRR"){
            R_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == " + "){
        
        }
    
    } else { # 未出结果(一般是文件未到齐)
        if(STATE_SYMBLE == " - "){
            _str=CURRENT_COMPARE_TYPE
            gsub(/_/,".*", _str); 
            # print _str
            split(_str,_ARR, "+");
            TYPE    =    "#";
            # print FILE_NAME,_ARR[1],_ARR[2],_ARR[3],match(FILE_NAME,_ARR[1])
            if(match(FILE_NAME,_ARR[1])){
                TYPE=  M3_FLAG ? "A" : "L";
                sub(/\| - \|/,"U| "TYPE" |", ONEROW);
                UNMATCH_CNT ++;
                INCOMING_VALID_SIZE_M += FILE_SIZE_M;
                A_FILE_ROW = ONEROW;
                next;    
            } else if(match(FILE_NAME,_ARR[2])){
                TYPE=  M3_FLAG ? "B" : "R";
                sub(/\| - \|/,"U| "TYPE" |", ONEROW); 
                UNMATCH_CNT ++;
                INCOMING_VALID_SIZE_M += FILE_SIZE_M;
                B_FILE_ROW = ONEROW;
                next
            } else if(match(FILE_NAME,_ARR[3]) && M3_FLAG){
                TYPE="C";
                sub(/\| - \|/,"U| "TYPE" |", ONEROW); 
                UNMATCH_CNT ++;
                INCOMING_VALID_SIZE_M += FILE_SIZE_M;
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
        TYPE    =    "#";
        # print _ARR[1],_ARR[2],_ARR[3]
        if(match(ONEROW,_ARR[1]) || match(ONEROW,_ARR[2]) ||
        (M3_FLAG && match(ONEROW,_ARR[3]))){
            
            HAVE_FURDER++;
            NEW_COMING_FLAG    = 1;
            sub(/ \|/,"N|", ONEROW);
        } 
    }
    
    SHOW_LINES    =    SHOW_LINES""ONEROW"\n";

}

END{
    FORMAT_LINE="\n\n\n  ***  目标:\n"
    FORMAT_LINE=FORMAT_LINE"  ***  月全量总结果数: %d  双方个数: %d  三方个数: %d\n";
    FORMAT_LINE=FORMAT_LINE"  ***  每月需要文件总数: %d  双方文件: %d  三方文件: %d\n\n"

    FORMAT_LINE=FORMAT_LINE"  ***  本月 MONTH_INCOMING 状态汇总:\n"
    FORMAT_LINE=FORMAT_LINE"  ***  传输文件总大小: %6.2f (G)  有效文件总大小: %6.2f (G) \n";
    FORMAT_LINE=FORMAT_LINE"  ***  传输总数: %d  匹配成功: %d 等待匹配: %d  还差: %d\n";
    FORMAT_LINE=FORMAT_LINE"  ***  文件个数有效百分比: %6.2f %  文件大小有效百分百: %6.2f % \n\n";
    
    FORMAT_LINE=FORMAT_LINE"  ***  结果统计 MONTH_TWO(THREE)_FILE_COMPARE  统计汇总：\n"
    FORMAT_LINE=FORMAT_LINE"  ***  强制重跑: %d  有新文件未处理的结果个数： %d\n";
    FORMAT_LINE=FORMAT_LINE"  ***  双方通过：%3d  未通过：%3d  结果校验出错：%3d 未出结果(文件未到齐或正在处理): %d \n";
    FORMAT_LINE=FORMAT_LINE"  ***  三方通过：%3d  未通过：%3d  结果校验出错：%3d 未出结果(文件未到齐或正在处理): %d \n";

    
    
    # FORMAT_LINE=FORMAT_LINE"# 总结果数： %d\n";
    
    VALID_CNT       =   UNMATCH_CNT+USE_FOR_RESULT_CNT;
    VALID_CNT_RATIO = (VALID_CNT/INCOMING_CNT)*100;
    VALID_SIZE_RATIO = (INCOMING_VALID_SIZE_M/INCOMING_TOTAL_SIZE_M)*100;
    
    M2_TOTAL_CNT    =   PASS2WAY + CHECK_ERROR2_CNT + UNPASS2WAY + WAITING2_FILES;
    M3_TOTAL_CNT    =   PASS3WAY + CHECK_ERROR3_CNT + UNPASS3WAY + WAITING3_FILES;
    
    MONTH_TOTAL_VALID_CNT   =   M3_TOTAL_CNT * 3 +  M2_TOTAL_CNT * 2;
    
    printf(FORMAT_LINE,\
    ALL_RESULT,M2_TOTAL_CNT,M3_TOTAL_CNT,\
    MONTH_TOTAL_VALID_CNT, M2_TOTAL_CNT * 2, M3_TOTAL_CNT * 3,\
    INCOMING_TOTAL_SIZE_M/1024, INCOMING_VALID_SIZE_M/1024,\
    INCOMING_CNT, USE_FOR_RESULT_CNT,UNMATCH_CNT,MONTH_TOTAL_VALID_CNT - VALID_CNT,\
    VALID_CNT_RATIO,VALID_SIZE_RATIO,\
    FORCE_REDO_LINE, HAVE_FURDER,\
    PASS2WAY,UNPASS2WAY,CHECK_ERROR2_CNT,WAITING2_FILES,\
    PASS3WAY,UNPASS3WAY,CHECK_ERROR3_CNT,WAITING3_FILES);
}