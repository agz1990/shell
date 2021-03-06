#!/usr/bin/awk    -f

########################################################################
# Author      : jigc 
# Script Name : merge-result-incoming-table.awk
# Date        : 2015-9-12
# Description : 将双方，三方结果表与incoming表合并
# Version     : V1.0
# Usage       : 
# Log:
#
########################################################################

BEGIN{
    FS="[[:space:]]+"
    
    COMPARE_RATDO_THRESHOLD    =    90;
    DEFAULT_RESULT_TIME        =     "2000-01-01#00:00:00";
    DEFAULT_RESULT_TIME2       =     "2000-01-01 00:00:00";
    INCOMING_CNT               =     0;
    INCOMING_VALID_CNT         =     0;
    INCOMING_TOTAL_SIZE        =     0;
    INCOMING_VALID_SIZE        =     0;
    
    
    
    # FORC RESULT2_ARRAY
    __RET2_BIZ_PRIVINCE_CODE        =    2;
    __RET2_L_FILE_NAME              =    3;
    __RET2_R_FILE_NAME              =    4;
    __RET2_COMPARE_TYPE             =    5;
    __RET2_CREATE_TIME              =    6;
    __RET2_COMFORM_RATIO            =    7;
    __RET2_CREATE_TIME_STAMP        =    8;
    __RET2_L_UNMATCH                =    9;
    __RET2_R_UNMATCH                =    10;
    __RET2_L_REPEAT_RECORD          =    11;
    __RET2_R_REPEAT_RECORD          =    12;
    __RET2_L_RECORD_TOTAL           =   13;
    __RET2_R_RECORD_TOTAL           =   14;
    
    # FOR RESULT3_ARRAY
    __RET3_BIZ_PRIVINCE_CODE        =    2;
    __RET3_A_FILE_NAME              =    3;
    __RET3_B_FILE_NAME              =    4;
    __RET3_C_FILE_NAME              =    5;
    __RET3_COMPARE_TYPE             =    6;
    __RET3_CREATE_TIME              =    7;
    __RET3_COMFORM_RATIO            =    8;
    __RET3_CREATE_TIME_STAMP        =    9;
    __RET3_N1                       =    10;
    __RET3_N2                       =    11;
    __RET3_N3                       =    12;
    __RET3_N4                       =    13;
    __RET3_N5                       =    14;
    __RET3_N6                       =    15;
    __RET3_N7                       =    16;
    __RET3_A_REPEAT_RECORD          =    17;
    __RET3_B_REPEAT_RECORD          =    18;
    __RET3_C_REPEAT_RECORD          =    19;
    __RET3_A_RECORD_TOTAL           =   20;
    __RET3_B_RECORD_TOTAL           =   21;
    __RET3_C_RECORD_TOTAL           =   22;
                                         
    
    # FOR MONTH_INCOMING
    __MICM_BIZ_PRIVINCE_CODE        =    2;            
    __MICM_FILE_NAME                =    3;
    __MICM_FILE_SIZE                =    4;
    __MICM_CKSUM_VALUE              =    5;
    __MICM_STATE                    =    6;
    __MICM_RESEND_NUM               =    7;
    __MICM_VALIDITY                 =    8;
    __MICM_INCOMING_TIME            =    9;
    __MICM_INCOMING_TIME_STAMP      =    10;
    
}


function recheckresultLine(result_line){
    # print "abc "result_line
    pass_flag=0;
    split(result_line, _RET,"|");
    if(match(result_line, /M2\|$/)){
        left_file_pattern = sprintf(".%010s.gz", _RET[__RET2_L_RECORD_TOTAL]);
        
        right_file_pattern = sprintf(".%010s.gz", _RET[__RET2_R_RECORD_TOTAL]);
        # print "PATTERN:"left_file_pattern"|"right_file_pattern
        if(match(_RET[__RET2_L_FILE_NAME],left_file_pattern) && 
           match(_RET[__RET2_R_FILE_NAME],right_file_pattern)) {
            pass_flag=1;
         }
    } else  if(match(result_line, /M3|$/)){
    
        A_file_pattern = sprintf(".%010s.gz", _RET[__RET3_A_RECORD_TOTAL]);
        
        B_file_pattern = sprintf(".%010s.gz", _RET[__RET3_B_RECORD_TOTAL]);
        
        C_file_pattern = sprintf(".%010s.gz", _RET[__RET3_C_RECORD_TOTAL]);
      
        if(match(_RET[__RET3_A_FILE_NAME],A_file_pattern) && 
           match(_RET[__RET3_B_FILE_NAME],B_file_pattern) && 
           match(_RET[__RET3_C_FILE_NAME],C_file_pattern)) {
            pass_flag=1;
         }
    }
    
    return pass_flag;
}


function getOneFileSideSymble(file_name,compare_way){

    _str=compare_way

    gsub(/_/,".*", _str); 
    split(_str,_ARR, "+");
    TYPE    =    "-";
    # print file_name,_ARR[1],_ARR[2],_ARR[3],match(file_name,_ARR[1])
    
    M3_FLAG = length(_ARR[3]) ? 1 : 0;
    
    if(match(file_name,_ARR[1])){
        TYPE=  M3_FLAG ? "A" : "L";
    } else if(match(file_name,_ARR[2])){
        TYPE=  M3_FLAG ? "B" : "R";
    } else if(match(file_name,_ARR[3])){
        TYPE= M3_FLAG ? "C" : "-";
    } 
    return TYPE;
}

NF == 13 && $0 ~ /RESULT2$/ {
    
    
    # 0005100
    BIZ_PRIVINCE_CODE    =    $1;
    
    # FLAT_20150815010000_0005100.0002241498.gz
    L_FILE_NAME          =    $2;
    
    # BOSS_20150815010000_0005100.0002216201.gz
    R_FILE_NAME          =    $3;
    
    # 对比类型 FLAT_0005+BOSS_0005+VGOP_0005
    COMPARE_TYPE         =    $4;
    
    # 时间字符串 2015-08-25#19:11:00
    CREATE_TIME          =    $5;
    if(match(CREATE_TIME,"NULL")){
        CREATE_TIME = DEFAULT_RESULT_TIME;
    }
    _timstr=CREATE_TIME;
    gsub(/[#:-]/," ", _timstr);
    CREATE_TIME_STAMP=mktime(_timstr);
    sub(/#/," ", CREATE_TIME);
    
    # 正确率
    COMFORM_RATIO        =    $6;
    
    # LEFT_UNMATCH,RIGHT_UNMATCH
    L_UNMATCH            =    $7;
    R_UNMATCH            =    $8;

    
    # 重复记录数
    L_REPEAT_RECORD      =    $9;
    R_REPEAT_RECORD      =    $10;
    
    
    # 文件记录总数
    L_RECORD_TOTAL        =    $11;
    R_RECORD_TOTAL        =    $12;

    
    
    _format="|%s|%41s|%41s|%s|%19s|%6.2f|%011s|%s|%s|%s|M2|"
    RESULT2_ARRAY[BIZ_PRIVINCE_CODE]=sprintf(_format,\
    BIZ_PRIVINCE_CODE,\
    L_FILE_NAME,R_FILE_NAME,COMPARE_TYPE,\
    CREATE_TIME,COMFORM_RATIO,CREATE_TIME_STAMP,\
    L_UNMATCH"|"R_UNMATCH,\
    L_REPEAT_RECORD"|"R_REPEAT_RECORD,\
    L_RECORD_TOTAL"|"R_RECORD_TOTAL);
    
    # print RESULT2_ARRAY[BIZ_PRIVINCE_CODE]
    KEY_ORDER2_ARRAY[RESULT2_CNT++] = BIZ_PRIVINCE_CODE;
    
    next;
    
}


NF == 21 && $0 ~ /RESULT3$/ {
    
    # 0005100
    BIZ_PRIVINCE_CODE    =    $1;
    
    # FLAT_20150815010000_0005100.0002241498.gz
    A_FILE_NAME          =    $2;
    
    # BOSS_20150815010000_0005100.0002216201.gz
    B_FILE_NAME          =    $3;
    
    # VGOP_20150815010000_0005100.0002242968.gz
    C_FILE_NAME          =    $4;
    
    # 对比类型 FLAT_0005+BOSS_0005+VGOP_0005
    COMPARE_TYPE         =    $5;
    
    # 时间字符串 2015-08-25#19:11:00
    CREATE_TIME          =    $6;
    if(match(CREATE_TIME,"NULL")){
        CREATE_TIME = DEFAULT_RESULT_TIME;
    }
    _timstr=CREATE_TIME;
    gsub(/[#:-]/," ", _timstr);
    CREATE_TIME_STAMP=mktime(_timstr);
    sub(/#/," ", CREATE_TIME);
    
    # 正确率
    COMFORM_RATIO        =    $7;
    
    # N1~N7
    N1    =    $8;
    N2    =    $9;
    N3    =    $10;
    N4    =    $11;
    N5    =    $12
    N6    =    $13;
    N7    =    $14;
    
    # 重复记录数
    A_REPEAT_RECORD        =    $15;
    B_REPEAT_RECORD        =    $16;
    C_REPEAT_RECORD        =    $17;
    
    # 文件记录总数
    A_RECORD_TOTAL        =    $18;
    B_RECORD_TOTAL        =    $19;
    C_RECORD_TOTAL        =    $20;
    
    
    _format="|%s|%41s|%41s|%41s|%s|%19s|%6.2f|%011s|%s|%s|%s|M3|"
    RESULT3_ARRAY[BIZ_PRIVINCE_CODE]=sprintf(_format,\
    BIZ_PRIVINCE_CODE,\
    A_FILE_NAME,B_FILE_NAME,C_FILE_NAME,COMPARE_TYPE,\
    CREATE_TIME,COMFORM_RATIO,CREATE_TIME_STAMP,\
    N1"|"N2"|"N3"|"N4"|"N5"|"N6"|"N7,\
    A_REPEAT_RECORD"|"B_REPEAT_RECORD"|"C_REPEAT_RECORD,\
    A_RECORD_TOTAL"|"B_RECORD_TOTAL"|"C_RECORD_TOTAL);
    
    
    KEY_ORDER3_ARRAY[RESULT3_CNT++] = BIZ_PRIVINCE_CODE;
    
    next;
    
}


NF == 9 && $0 ~ /MONTH_INCOMING$/ {
    BIZ_PRIVINCE_CODE    =    $1;
    FILE_NAME            =    $2;
    FILE_SIZE            =    $3;
    CKSUM_VALUE          =    $4;
    STATE                =    $5;
    RESEND_NUM           =    $6;
    VALIDITY             =    $7;
    INCOMING_TIME        =    $8;
    
    { # 通过date 命令解析字符串速度太慢
        # _timstr=INCOMING_TIME
        # sub(/#/," ", _timstr);
        
        # getline INCOMING_TIME_STAMP < "date" #"date -d "_timstr" +%s"
        # "date -d \""_timstr"\" +%s" | getline INCOMING_TIME_STAMP;
        # close("date -d \""_timstr"\" +%s")
    }
    
    if (BIZ_PRIVINCE_CODE == "NULL"){ # fix BIZ_PRIVINCE_CODE
        # FLAT_20150815010000_0005100.0002241498.gz
        if(length(FILE_NAME) == 41){
            BIZ_PRIVINCE_CODE = substr(FILE_NAME, 21, 7);
            
            sub(/^9045/,"0045",BIZ_PRIVINCE_CODE);
            # print "#####"BIZ_PRIVINCE_CODE, FILE_NAME;
        }
    }
    
    _timstr=INCOMING_TIME
    gsub(/[#:-]/," ", _timstr);
    INCOMING_TIME_STAMP=mktime(_timstr)
    gsub(/#/," ", INCOMING_TIME);
    
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
    for( _index_number = 0; _index_number < RESULT2_CNT; _index_number ++){
        
        L_FLAG    =    "---";
        R_FLAG    =    "---";
        
        
        _biz_privince_code     =    KEY_ORDER2_ARRAY[_index_number];
        
        split(RESULT2_ARRAY[_biz_privince_code], _RET,"|");
        CNT_KEY=_biz_privince_code"+CNT";
        
    
        MUL_LINE    =    "";
        HAVE_FURDER    =    0;
        for(i = 1; i < MONTH_INCOMING[CNT_KEY]; i++){
            
            
            INDEX_KEY    =    _biz_privince_code"+"i;
            split(MONTH_INCOMING[INDEX_KEY], _ONE_FILE_ROW,"|");
            LINE         =    MONTH_INCOMING[INDEX_KEY];
            FILE_NAME    =    _ONE_FILE_ROW[__MICM_FILE_NAME];
            STATE        =     _ONE_FILE_ROW[__MICM_STATE];
            
                        
            INCOMING_CNT ++;
            INCOMING_TOTAL_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE];
            if(_ONE_FILE_ROW[__MICM_INCOMING_TIME_STAMP] >= _RET[__RET2_CREATE_TIME_STAMP] && \
            ! match(_RET[__RET2_L_FILE_NAME],"NULL")){
                SIDE_SYMBLE = getOneFileSideSymble(FILE_NAME,_RET[__RET2_COMPARE_TYPE]);
                if(SIDE_SYMBLE != "-"){
                    HAVE_FURDER        =    1;
                    STATE_SYMBLE       =    " + "
                } else {
                    STATE_SYMBLE       =    " - "
                }
                # print SIDE_SYMBLE,RESULT2_ARRAY[_biz_privince_code]
            } else if(STATE == 4 || STATE == 6){
                STATE_SYMBLE    =    " ! ";
            } else if(FILE_NAME == _RET[__RET2_L_FILE_NAME]){
                STATE_SYMBLE    =    "LLL";
                L_FLAG          =    "LLL";
                INCOMING_VALID_CNT ++;
                INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]
            } else if(FILE_NAME == _RET[__RET2_R_FILE_NAME]) {
                STATE_SYMBLE    =    "RRR";
                R_FLAG          =    "RRR";
                INCOMING_VALID_CNT ++;
                INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]
            } else if(_RET[__RET2_CREATE_TIME] != DEFAULT_RESULT_TIME2){ # 如果已经有结果生成，其他文件则默认标记为 '-'
                STATE_SYMBLE    =    " - ";
            } else {
                
                SIDE_SYMBLE    =   getOneFileSideSymble(FILE_NAME,_RET[__RET2_COMPARE_TYPE]);
                if(SIDE_SYMBLE == "L"){
                    L_FLAG          =    "-L-";
                    STATE_SYMBLE    =    " L ";
                } else if (SIDE_SYMBLE == "R"){
                    R_FLAG          =    "-R-";
                    STATE_SYMBLE    =    " R ";
                } else {
                    STATE_SYMBLE    =    " - ";
                }
            }
            
            FILE_DETAIL_OUTPUT_FORMAT="|%s|%07s|%41s|%1d|%8.2f(M)|%12s|%19s|MI|\n";
            LINE=sprintf(FILE_DETAIL_OUTPUT_FORMAT, \
            STATE_SYMBLE,\
            _ONE_FILE_ROW[__MICM_BIZ_PRIVINCE_CODE],\
            _ONE_FILE_ROW[__MICM_FILE_NAME],\
            _ONE_FILE_ROW[__MICM_STATE],\
            _ONE_FILE_ROW[__MICM_FILE_SIZE]/1024/1024,\
            _ONE_FILE_ROW[__MICM_CKSUM_VALUE],\
            _ONE_FILE_ROW[__MICM_INCOMING_TIME])
            
            MUL_LINE    =    MUL_LINE"         "LINE;
        }
        # print "@"L_FLAG,R_FLAG,VALID_RESULT
        RESULT2_OUTPUT_FORMAT="|%s|%s|%6.2f%%|%3s|%3s|%19s|%s|-|M2|\n";
        
        MATCHED_FALG       =    "-";
        VALID_RESULT       =    "-";
        RESULT_CHECK       =    "-";
        VALID_RATIO        =    "-";
        FURDER_RESULT      =    "%";
        # print 
        
        if(L_FLAG == "LLL" && R_FLAG == "RRR"){
            MATCHED_FALG         =    "%";
            VALID_RESULT    =    "%"
            
            if(recheckresultLine(RESULT2_ARRAY[_biz_privince_code])){ # 校验双方结果是否正确
                # 校验通过
                RESULT_CHECK="%";
                # print "PASS:"_RET[__RET2_BIZ_PRIVINCE_CODE]"|"_RET[__RET2_L_RECORD_TOTAL]"|"_RET[__RET2_R_RECORD_TOTAL]
            }else{
                # print "UNPASS:"_RET[__RET2_BIZ_PRIVINCE_CODE]"|"_RET[__RET2_L_RECORD_TOTAL]"|"_RET[__RET2_R_RECORD_TOTAL]
            }
            
            if(RESULT_CHECK == "%" && _RET[__RET2_COMFORM_RATIO] >= COMPARE_RATDO_THRESHOLD) 
            {
                VALID_RATIO     =    "%"
            } 
            
            if(RESULT_CHECK == "%" && _RET[__RET2_COMFORM_RATIO] == 0 &&
            (_RET[__RET2_L_RECORD_TOTAL] == 0 || _RET[__RET2_R_RECORD_TOTAL] == 0)){
                
                 VALID_RATIO     =    "%"
            }
            
            # print "####"RESULT_CHECK"|"_biz_privince_code"|"_RET[__RET2_COMFORM_RATIO] "|"_RET[__RET2_L_RECORD_TOTAL]"|" _RET[__RET2_R_RECORD_TOTAL]"#"VALID_RATIO"#"(_RET[__RET2_R_RECORD_TOTAL] == 0)
            if(HAVE_FURDER){
                FURDER_RESULT    =    "-";
            }
        } else if(L_FLAG == "-L-" && R_FLAG == "-R-"){ 
            MATCHED_FALG         =    "%";
        } else {
            MATCHED_FALG         =    "-"
        }
        
        
        printf(RESULT2_OUTPUT_FORMAT, \
        MATCHED_FALG""VALID_RESULT""RESULT_CHECK""VALID_RATIO""FURDER_RESULT,\
        _RET[__RET2_BIZ_PRIVINCE_CODE],_RET[__RET2_COMFORM_RATIO],\
        L_FLAG,R_FLAG,\
        _RET[__RET2_CREATE_TIME],\
        _RET[__RET2_COMPARE_TYPE]);
        sort MUL_LINE
        print MUL_LINE # | "sort -t '|' -k 7" | 
    }

    for( _index_number = 0; _index_number < RESULT3_CNT; _index_number ++){
        
        A_FLAG    =    "---";
        B_FLAG    =    "---";
        C_FLAG    =    "---";
        
        _biz_privince_code     =    KEY_ORDER3_ARRAY[_index_number];
        
        split(RESULT3_ARRAY[_biz_privince_code], _RET,"|");
        CNT_KEY=_biz_privince_code"+CNT";
        
    
        MUL_LINE       =    "";
        HAVE_FURDER    =    0;
        for(i = 1; i < MONTH_INCOMING[CNT_KEY]; i++){

            
            INDEX_KEY    =    _biz_privince_code"+"i;
            split(MONTH_INCOMING[INDEX_KEY], _ONE_FILE_ROW,"|");
            LINE         =    MONTH_INCOMING[INDEX_KEY];
            FILE_NAME    =    _ONE_FILE_ROW[__MICM_FILE_NAME];
            STATE        =     _ONE_FILE_ROW[__MICM_STATE];
            
                        
            INCOMING_CNT ++;
            INCOMING_TOTAL_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE];
            # print _RET[__RET3_A_FILE_NAME],_RET[__RET3_B_FILE_NAME],_RET[__RET3_C_FILE_NAME]
            if(_ONE_FILE_ROW[__MICM_INCOMING_TIME_STAMP] >= _RET[__RET3_CREATE_TIME_STAMP] && \
            ! match(_RET[__RET3_A_FILE_NAME],"NULL")){
                SIDE_SYMBLE = getOneFileSideSymble(FILE_NAME,_RET[__RET3_COMPARE_TYPE]);
                print _biz_privince_code, SIDE_SYMBLE
                if(SIDE_SYMBLE != "-"){
                    HAVE_FURDER        =    1;
                    STATE_SYMBLE       =    " + "
                } else {
                    STATE_SYMBLE       =    " - "
                }
               
            } else if(STATE == 4 || STATE == 6){
                STATE_SYMBLE    =    " ! ";
            } else if(FILE_NAME == _RET[__RET3_A_FILE_NAME]){
                STATE_SYMBLE      =    "AAA";
                A_FLAG            =    "AAA";
                INCOMING_VALID_CNT ++;
                INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]
            } else if(FILE_NAME == _RET[__RET3_B_FILE_NAME]) {
                STATE_SYMBLE      =    "BBB";
                B_FLAG            =    "BBB";
                INCOMING_VALID_CNT ++;
                INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]                
            } else if(FILE_NAME == _RET[__RET3_C_FILE_NAME]) {
                STATE_SYMBLE      =    "CCC";
                C_FLAG            =    "CCC";
                INCOMING_VALID_CNT ++;
                INCOMING_VALID_SIZE += _ONE_FILE_ROW[__MICM_FILE_SIZE]                    
            } else if(_RET[__RET3_CREATE_TIME] != DEFAULT_RESULT_TIME2){ # 如果已经有结果生成，其他文件则默认标记为 '-'
                STATE_SYMBLE    =    " - ";
            } else {
                SIDE_SYMBLE    =   getOneFileSideSymble(FILE_NAME,_RET[__RET3_COMPARE_TYPE]);
                if(SIDE_SYMBLE == "A"){
                    A_FLAG          =    "-A-";
                    STATE_SYMBLE    =    " A ";
                } else if (SIDE_SYMBLE == "B"){
                    B_FLAG          =    "-B-";
                    STATE_SYMBLE    =    " B ";
                } else if (SIDE_SYMBLE == "C"){
                    C_FLAG          =    "-C-";
                    STATE_SYMBLE    =    " C ";
                } else {
                    STATE_SYMBLE    =    " - ";
                }
            }
            
            FILE_DETAIL_OUTPUT_FORMAT="|%s|%07s|%41s|%1d|%8.2f(M)|%12s|%19s|MI|\n";
            LINE=sprintf(FILE_DETAIL_OUTPUT_FORMAT, \
            STATE_SYMBLE,\
            _ONE_FILE_ROW[__MICM_BIZ_PRIVINCE_CODE],\
            _ONE_FILE_ROW[__MICM_FILE_NAME],\
            _ONE_FILE_ROW[__MICM_STATE],\
            _ONE_FILE_ROW[__MICM_FILE_SIZE]/1024/1024,\
            _ONE_FILE_ROW[__MICM_CKSUM_VALUE],\
            _ONE_FILE_ROW[__MICM_INCOMING_TIME])
            
            MUL_LINE    =    MUL_LINE"         "LINE;
        }
        
        
        VALID_RESULT       =    "-"
        RESULT_CHECK       =    "-"
        VALID_RATIO        =    "-"
        FURDER_RESULT      =    "%";
        
        RESULT3_OUTPUT_FORMAT="|%s|%s|%6.2f%%|%3s|%3s|%3s|%19s|%s|-|M3|\n";
        if(A_FLAG == "AAA" && B_FLAG == "BBB" && C_FLAG == "CCC"){
            VALID_RESULT    =    "%"
            MATCHED_FALG         =    "%";
            
            if(recheckresultLine(RESULT3_ARRAY[_biz_privince_code])){ # 校验双方结果是否正确
                # 校验通过
                RESULT_CHECK="%";
                # print "PASS:"_RET[__RET2_BIZ_PRIVINCE_CODE]"|"_RET[__RET2_L_RECORD_TOTAL]"|"_RET[__RET2_R_RECORD_TOTAL]
            }else{
                # print "UNPASS:"_RET[__RET2_BIZ_PRIVINCE_CODE]"|"_RET[__RET2_L_RECORD_TOTAL]"|"_RET[__RET2_R_RECORD_TOTAL]
            }
        
             
            if(RESULT_CHECK == "%" && _RET[__RET3_COMFORM_RATIO] >= COMPARE_RATDO_THRESHOLD){
                VALID_RATIO     =    "%"
            } 
            
            if(RESULT_CHECK == "%" && _RET[__RET3_COMFORM_RATIO] == 0 &&
            (_RET[__RET3_A_RECORD_TOTAL] == 0 ||  _RET[__RET3_B_RECORD_TOTAL]  == 0 || _RET[__RET3_C_RECORD_TOTAL]  != 0)){
                
                 VALID_RATIO     =    "%"
            }
            if(HAVE_FURDER){
                FURDER_RESULT    =    "-";
            }
            
        } else if(A_FLAG == "-A-" && B_FLAG == "-B-" && C_FLAG == "-C-"){ 
            MATCHED_FALG         =    "%";
        } else {
            MATCHED_FALG         =    "-";
        }
    
        printf(RESULT3_OUTPUT_FORMAT, \
        MATCHED_FALG""VALID_RESULT""RESULT_CHECK""VALID_RATIO""FURDER_RESULT,\
        _RET[__RET3_BIZ_PRIVINCE_CODE],_RET[__RET3_COMFORM_RATIO],\
        A_FLAG,B_FLAG,C_FLAG,\
        _RET[__RET3_CREATE_TIME],\
        _RET[__RET3_COMPARE_TYPE]);
        sort MUL_LINE
        print MUL_LINE # | "sort -t '|' -k 7" | 
    }

    FORMAT_LINE="\n\n\n  ***  本月传输文件数:： %d  有效文件数: %d\n";
    FORMAT_LINE=FORMAT_LINE"  ***  文件总大小: %6.2f (G)  有效文件总大小: %6.2f (G) \n";
    FORMAT_LINE=FORMAT_LINE"  ***  文件有效百分百: %6.2f %  文件大小有效百分百: %6.2f % \n";
    
    # printf (FORMAT_LINE,
    # INCOMING_CNT,INCOMING_VALID_CNT, 
    # INCOMING_TOTAL_SIZE/1024/1024/1024,INCOMING_VALID_SIZE/1024/1024/1024,
    # (INCOMING_VALID_CNT/INCOMING_CNT)*100, (INCOMING_VALID_SIZE/INCOMING_TOTAL_SIZE)*100);
    
}