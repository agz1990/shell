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
    WAITING2_COMPARE =   0;
    WAITING3_COMPARE =   0;
    HAVE_FURDER      =   0;
    FORCE_REDO_LINE  =   0;
    
    INCOMING_CNT    =   0;
    WAITING_FIMES_CNT = 0;
    USE_FOR_RESULT_CNT      =   0;  # 已经生成结果的文件
    INCOMING_TOTAL_SIZE_M   =   0;  # 所有文件总大小
    HAVING_RESULT_SIZE_M    =   0;  # 出结果的文件总大小
    WAITING_COMPARE_SIZE_M  =   0;  # 匹配成功但是未出结果的文件总大小
    UNMATCH_SIZE_M          =   0;  # 未匹配成功的文件大小      
    
    MARK_SYMBLE_FLAG        =   "BR"
    # awk -f suggest-redo-list.awk FORCE_PATTERN="00822.." ./output/month_redo_output_201508.20150914163440
}

function dumpOneResult(){

    if ( CURRENT_RESULT && \
        (!HAVE_RESULT_FLAG || \
         !RESUL_CHECK_SUCCESS_FLAG || \
         !RESUL_PASS_THRESHOLD_FLAG || \
         NEW_COMING_FLAG || \
         FORCE_REDO_FALG)){
    
        if(!RESUL_PASS_THRESHOLD_FLAG || FORCE_REDO_FALG) {
            sub(/\|-\|/,"|R|", CURRENT_RESULT); 
        }
    
        
        NEW_COMING_FLAG        = 0;
        FORCE_REDO_FALG        = 0;
        
        printf("%s\n",CURRENT_RESULT);
        
        if(A_FILE_ROW) printf("%s\n",A_FILE_ROW); 
        if(B_FILE_ROW) printf("%s\n",B_FILE_ROW); 
        if(C_FILE_ROW) printf("%s\n",C_FILE_ROW); 
        if(L_FILE_ROW) printf("%s\n",L_FILE_ROW); 
        if(R_FILE_ROW) printf("%s\n",R_FILE_ROW); 
        
        
        printf("%s",SHOW_LINES);
        
        
    }

}


/\|M[23]\|$/ { 
    
    dumpOneResult();
    
    split($2,__FLAGS,"");
    
    MATCHED_FALG                =    __FLAGS[1] == "%" ? 1 : 0;
    HAVE_RESULT_FLAG            =    __FLAGS[2] == "%" ? 1 : 0;
    RESUL_CHECK_SUCCESS_FLAG    =    __FLAGS[3] == "%" ? 1 : 0;
    RESUL_PASS_THRESHOLD_FLAG   =    __FLAGS[4] == "%" ? 1 : 0;
    HAVE_FURTER_FLAG            =    __FLAGS[5] == "%" ? 1 : 0;
    BIZ_PRIVINCE_CODE           =    $3;
    A_FLAG                      =    $5
    B_FLAG                      =    $6
    C_FLAG                      =    $7
    

    CURRENT_RESULT     = $0;
    M3_FLAG            =    match(CURRENT_RESULT, /\|M3\|$/);
    CURRENT_COMPARE_TYPE = $(NF-3)
    SHOW_LINES = "";
    A_FILE_ROW = "";
    B_FILE_ROW = "";
    C_FILE_ROW = "";
    L_FILE_ROW = "";
    R_FILE_ROW = "";
    
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
       
    } else if(MATCHED_FALG){    # 还未得出结果
         if(M3_FLAG){
         
            UNMATCH_CNT+=3;
            WAITING3_COMPARE ++;
         }
         else {
            UNMATCH_CNT+=2;
            WAITING2_COMPARE ++;
         }
           
    } else { # 文件未到齐
    
        if(M3_FLAG) {
            WAITING3_FILES++;
        }
        else {
            WAITING2_FILES++;
        }

        if(A_FLAG == "---"){
           WAITING_FIMES_CNT++;
        }else{
            UNMATCH_CNT++;
        }
        
        if(B_FLAG == "---"){
            WAITING_FIMES_CNT++;
        }else {
            UNMATCH_CNT++;
        }
        
        if(M3_FLAG && C_FLAG == "---"){
            WAITING_FIMES_CNT++;
        }else {
            UNMATCH_CNT
        }
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
        HAVING_RESULT_SIZE_M += FILE_SIZE_M;
    }

    if(MATCHED_FALG){
    
        if(HAVE_RESULT_FLAG){
            if(!RESUL_CHECK_SUCCESS_FLAG){
                MARK_SYMBLE =   "E";
            } else if(!RESUL_PASS_THRESHOLD_FLAG){
                MARK_SYMBLE =   "R"
            } else if(FORCE_REDO_FALG) {
                MARK_SYMBLE =   "F"
            }
        } else {
             MARK_SYMBLE =   "+";
        }
        
        PATTERN=".["MARK_SYMBLE_FLAG"].";
        # if( match(STATE_SYMBLE,PATTERN)) sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
        
    
        if(STATE_SYMBLE == "AAA" || STATE_SYMBLE == " A " ){
            # TODO 判断 taskman 是否重启过，如果重启时间在结果时间之前则需呀全部拷贝进行重跑 
            if(match(STATE_SYMBLE,PATTERN)) sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
            A_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == "BBB" || STATE_SYMBLE == " B "){
            if(match(STATE_SYMBLE,PATTERN)) sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
            B_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == "CCC" || STATE_SYMBLE == " C "){
            if(match(STATE_SYMBLE,PATTERN)) sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
            C_FILE_ROW = ONEROW;
            next;
        } else if(STATE_SYMBLE == "LLL" || STATE_SYMBLE == " L "){
            if(match(STATE_SYMBLE,PATTERN)) sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
            L_FILE_ROW    = ONEROW;
            next;
        } else if(STATE_SYMBLE == "RRR" || STATE_SYMBLE == " R "){
            if(match(STATE_SYMBLE,PATTERN)) sub(/ \|/,MARK_SYMBLE"|", ONEROW); 
            R_FILE_ROW = ONEROW;
            next;
        } 
    
    }
    
    if(MATCHED_FALG && !HAVE_RESULT_FLAG){
        WAITING_COMPARE_SIZE_M += FILE_SIZE_M;
    }else if(!MATCHED_FALG){
        UNMATCH_SIZE_M += FILE_SIZE_M;
    }
    
    


    if(STATE_SYMBLE == " + "){
        
        _str=CURRENT_COMPARE_TYPE
        gsub(/_/,".*", _str); 
        # print CURRENT_COMPARE_TYPE
        split(_str,_ARR, "+");
        TYPE    =    "#";
        # print ONEROW,_ARR[1],_ARR[2],_ARR[3]
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
    FORMAT_LINE=FORMAT_LINE"  ***  传输总数: %d  等待比对: %d  等待重传: %d \n";
    FORMAT_LINE=FORMAT_LINE"  ***  传输文件总大小: %6.2f (G)  跑出结果: %6.2f (G)  等待比对: %6.2f (M) 等待匹配: %6.2f (M)\n\n";

    
    FORMAT_LINE=FORMAT_LINE"  ***  结果统计 MONTH_TWO(THREE)_FILE_COMPARE  统计汇总：\n"
    FORMAT_LINE=FORMAT_LINE"  ***  重跑标记方: '%s'  强制重跑: %d  有新文件未处理的结果个数： %d\n";
    FORMAT_LINE=FORMAT_LINE"  ***  【双方】 文件未到齐：%3d;  未得出比对结果: %3d;  结果校验出错：%3d;  通过率未达标：%3d; 双方通过：%3d \n";
    FORMAT_LINE=FORMAT_LINE"  ***  【三方】 文件未到齐：%3d;  未得出比对结果: %3d;  结果校验出错：%3d;  通过率未达标：%3d; 三方通过：%3d \n";

    
       
    
    
    # FORMAT_LINE=FORMAT_LINE"# 总结果数： %d\n";
    
    
    M2_TOTAL_CNT    =  WAITING2_FILES + WAITING2_COMPARE + CHECK_ERROR2_CNT + UNPASS2WAY +PASS2WAY;
    M3_TOTAL_CNT    =  WAITING3_FILES + WAITING3_COMPARE + CHECK_ERROR3_CNT + UNPASS3WAY +PASS3WAY;
    
    MONTH_TOTAL_VALID_CNT   =   M3_TOTAL_CNT * 3 +  M2_TOTAL_CNT * 2;
    
    printf(FORMAT_LINE,\
    ALL_RESULT,M2_TOTAL_CNT,M3_TOTAL_CNT,\
    MONTH_TOTAL_VALID_CNT, M2_TOTAL_CNT * 2, M3_TOTAL_CNT * 3,\
    INCOMING_CNT, UNMATCH_CNT, WAITING_FIMES_CNT,\
    INCOMING_TOTAL_SIZE_M/1024, (HAVING_RESULT_SIZE_M+1)/1024,WAITING_COMPARE_SIZE_M,UNMATCH_SIZE_M,\
    MARK_SYMBLE_FLAG,FORCE_REDO_LINE, HAVE_FURDER,\
    WAITING2_FILES,WAITING2_COMPARE,CHECK_ERROR2_CNT,UNPASS2WAY,PASS2WAY,\
    WAITING3_FILES,WAITING3_COMPARE,CHECK_ERROR3_CNT,UNPASS3WAY,PASS3WAY);
}