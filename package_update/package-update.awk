#!/user/bin/awk -f

########################################################################
# Author      : jigc 
# Script Name : dumpValidFilelist.awk
# Date        : 2014-12-01
# Description :
# Usage       : 
# Log:
#
########################################################################

BEGIN { 
	DEST_DIR=""
	HAS_CHECK_SUM_ERROR=0
}


/^[^#]/{
	cmd = sprintf ( "test  %s -eq `cksum %s| awk '{print $1}'` 	", $1,$2) 
	# print cmd

	if(system(cmd) != 0){
		printf ("File: %s  Check Sum ERROR. ",   $1)
	}else{
		# printf ("File: %s  Check Sum CURRECT. ",  $1 )
		if(NF == 2){
		}
		if(NF == 3){
			print 
		}
	}
}
END{
	print
	#print "\n\tTotal:" valid+inval+exclude " Valid" validHead ":" valid " Invalid" invalidHead ":" invalid " Exclude" excludeHead ":" exclude "\n"
}
