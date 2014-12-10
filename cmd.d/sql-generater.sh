#!/bin/sh
# sql-generater.sh  该脚本用来生成固件新架构 SQL 配置脚本、
# Author: jigc
# data: 2014-5-29

SHORT_KEY_TABLES="KEY_FUNC SHORT_STATE STATE_TIME_ZONE TIME_ZONE"
UPDATE_TABLES="APP_FUNC	APP_INFO	APP_PERMISSION  FUNC_LIST	ROLE	RES_LIST	KEY_CODE	KEY_FUNC SHORT_STATE STATE_TIME_ZONE TIME_ZONE"
DB_FILE="/mnt/mtdblock/data/ZKDB.db"

ATT_LOG_TABLE="ATT_LOG"

ORDER_NAME=$1

case `uname -n` in
	"ZMM100" )
		SQLIET="/mnt/mtdblock/data/sqlite3_arm"
		ECHO="echo -e"
		;;
	"ZMM220" ) 
		SQLIET="/mnt/mtdblock/data/sqlite3_mips"
		ECHO="echo -e"
		;;
	"(none)" ) 
		SQLIET="/mnt/mtdblock/data/sqlite3_mips"
		ECHO="echo -e"
		;;
	* ) 
		SQLIET="sqlite3"
		ECHO="echo"
	;;
esac


#UPDATE_TABLES=echo $UPDATE_TABLES | sort -u 

format (){

	cat <<-Head-of-message
############################################################
# FileName 	: $destFileName
# Create by	: sql-generater.sh
# DateTime	: `date`
# Describe	: $ORDER_NAME
############################################################

[CREATE_TABLE]
{
$(cat $@)
}
Head-of-message
}

generateSqlScript (){

	scriptName=$1
	> $scriptName
	until [ -z "$2" ]; do
		tableName=$2
		$SQLIET  $DB_FILE  1>/dev/null  <<-Cmd-of-message
		.output ${tableName}.sql
		.mode insert ${tableName} 
		SELECT * FROM ${tableName} ;
		.q
		Cmd-of-message
		
		if [ -f "${tableName}.sql" ]; then
			$ECHO  >> $scriptName
			$ECHO "delete from ${tableName} where 1=1;" >>  $scriptName
			cat  ${tableName}.sql >> $scriptName
			rm  ${tableName}.sql -rf
		fi
		
		shift
	done

}


generateCreatTableScript()
{
	fileName="CreatTable.sql"
	$SQLIET  $DB_FILE  1>/dev/null  <<-Cmd-of-message
		.output ${fileName}
		SELECT sql FROM sqlite_master WHERE name NOT LIKE "sqlite%" ORDER BY name;
		.q
		Cmd-of-message
		
		sed -e "s/\r$//;s/)$/);\n/"  -i  ${fileName}
		ARGS=$(sed -e 's/^CREATE TABLE \[\([^]]*\)\] ($/\1/p;  s/^CREATE TABLE \([^(]*\).*;$/\1/p' -n  ${fileName})
		echo $ARGS > table.txt
		 
		 generateSqlScript	tmp.sql $ARGS
		 format  ${fileName} tmp.sql  
		 rm $fileName table.txt -rf
}


generateSqlScript tmp.sql $UPDATE_TABLES
generateCreatTableScript > /mnt/mtdblock/update.sql
generateSqlScript tmp.sql $SHORT_KEY_TABLES
format tmp.sql  > /mnt/mtdblock/update_shortcutkey.sql



#format tmp.sql  update.sql

rm tmp.sql -rf
exit 0
