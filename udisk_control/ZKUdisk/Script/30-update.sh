#!/bin/sh

#
# 解压预制文件
#
TarUpdatePackage()
{

	DEBUG_LOG_FILE=$OUTPUT_DIR"/update.log"
	PACKAGE_DIR=$DATA_DIR"/update"
	DEST=$MACHINE_ROOT_DIR'/update'

	[ ! -d $DEST ] && mkdir $DEST -p

	if [ -d "$PACKAGE_DIR" ]; then
		for i in $(find  $PACKAGE_DIR -name '[0-9][0-9]-*.tgz' | sort) ; do
			echo "################################################################################"
			echo "Extrat: "$(basename $i)
			
			tar -zxvf $i -C $DEST		

			if [ "${IS_PC}" = "no" ]; then
				MvDir $DEST '/mnt/mtdblock'
			fi
			
			if [ "$?" = 0 ]; then
				echo "Extrat "$(basename $i)" Success...."
			else
				echo "Extrat :"$(basename $i)" Faile...."
			fi
			echo "\n"
			sync
	  	done 
		echo "################################################################################"
	fi  > $DEBUG_LOG_FILE
}

TarUpdatePackage

return 0
