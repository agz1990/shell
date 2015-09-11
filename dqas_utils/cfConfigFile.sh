#!/usr/bin/sh

# COPYRIGHT (C) Hewlett-Packard Company 2001 All rights reserved.
# The copyright to the computer program(s) herein is the property of 
# Hewlett-Packard Company 2001.
# The program(s) may be used and/or copied with the written permission
# from Hewlett-Packard Company 2001 or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.

# Revision 0.1  2001/11/27  lijun
# 	Initial revision
#

# Usage: cfConfigFile functions unix shell lib 
#

CFG_FILE_PATH=""
CFG_FILE_TYPE=""
CFG_FILE_ACCESS=""

CFG_SECTIONS=""
CFG_CUR_SECTION_NAME=""
CFG_CUR_ITEMLIST_NAME=""


#####################################################################
#
# Function Name : cfInit
#
# Description :  
#	init the cfConfigFile global variable
# Arguments:
#	$1 - config file path name
#  	$2 - file type(string):noLock ,withLock
#       $3 - file access mode(string): readOnly,readWrite
# Return Value:  
#       no return value
#####################################################################
cfInit()
{

	CFG_FILE_PATH=$1
	CFG_FILE_TYPE=$2
	CFG_FILE_ACCESS=$3
	
	CFG_SECTIONS=$(cfConfigFile getSectionList $1 $2 $3)
	CFG_CUR_SECTION_NAME=""
	CFG_CUR_ITEMLIST_NAME=""
}


#####################################################################
#
# Function Name : cfIsValid
#
# Description :  
#	judge  the cfConfigFile's global  variable if is valid
# Arguments:
#         no 
# Return Value:  
#  return value captured by $?, the function will "return 0" or "return 101 ..."
# 		the calling party will check by "if (( $? == 0 ))"
#####################################################################
cfIsValid()
{
   ret=0
   if [ "$CFG_FILE_PATH" = "" ]
   then  
	   ret=101
   fi
   if [ "$CFG_FILE_TYPE" = "" ]
   then
   	   ret=102
   fi
   if [ "$CFG_FILE_ACCESS" = "" ]
   then
   	   ret=103
   fi
   if [ "$CFG_SECTIONS"="" ]
   then
   	   ret=104
   fi
   return $ret	    
}

#####################################################################
#
# Function Name : cfGetConfigItem
#
# Description :  
#	get config value by section and name
# Arguments:
#	$1 - config section(string)
#  	$2 - config item name(string)
# Return Value:  
#	print 0 for get value is not null; 
#       the config item value
#####################################################################
cfGetConfigItem()
{
cfConfigFile getConfigItem $CFG_FILE_PATH $CFG_FILE_TYPE  $CFG_FILE_ACCESS $1 $2
}


#####################################################################
#
# Function Name : cfGetConfigItemListUnit
#
# Description :  
#	get config value's one unit by section and name and unit no
#       if the config value is split by ",",such as "item1,item2,item3,item4"
#          we can direct get the value "item3",by the parameter $3:3 
# Arguments:
#	$1 - config section(string)
#  	$2 - config item name(string)
#       $3 - config item unit no
# Return Value:  
#	print 0 for get value is not null; 
#####################################################################
cfGetConfigItemListUnit()
{
# $1 section
# $2 name
# $3 no.
   if [ "$CFG_CUR_SECTION_NAME"!="$1" -o  $CFG_CUR_ITEMLIST_NAME!="$2" ]
   then
       CFG_CUR_ITEMLIST_NAME=$(cfGetConfigItem $1 $2)
       CFG_CUR_SECTION_NAME=$1
   fi
   echo $CFG_CUR_ITEMLIST_NAME  | cut -d"," -f$3
}


#####################################################################
#
# Function Name : cfGetConfigSectList
#
# Description :  
#	get config sections 
#       sections is return such as : "common,section1,section2,section3"
#                          the section is split by ","
# Arguments:
#        no 
# Return Value:  
#	print 0 for get value is not null; 
#####################################################################
cfGetConfigSectList()
{ 
   echo $CFG_SECTIONS
}

#####################################################################
#
# Function Name : cfGetConfigSectListUnit
#
# Description :  
#	get config section's one by section no
#       if the CFG_SECTIONS value is split by ",",such as "sect1,sect2,sect3,sect4"
#          we can direct get the value "sect3",by the parameter $1:3 
# Arguments:
#       $1 - section no
# Return Value:  
#	print 0 for get value is not null; 
#####################################################################
cfGetConfigSectListUnit()
{
   echo $CFG_SECTIONS | cut -d"," -f$1
}

#####################################################################
#
# Function Name : cfRefresh
#
# Description :  
#	refresh the config content from file
# Arguments:
#          no
# Return Value:  
#  return value captured by $?, the function will "return 0" 
# 		the calling party will check by "if (( $? == 0 ))"
#####################################################################
cfRefresh()
{
cfConfigFile refresh $CFG_FILE_PATH $CFG_FILE_TYPE $CFG_FILE_ACCESS 
}

#####################################################################
#
# Function Name : cfSetConfigItem
#
# Description :  
#	set config value by section and name and value
# Arguments:
#	$1 - config section(string)
#  	$2 - config item name(string)
#       $3 - config item value(string)
# Return Value:  
#  return value captured by $?, the function will "return 0" 
# 		the calling party will check by "if (( $? == 0 ))"
#####################################################################
cfSetConfigItem()
{
cfConfigFile setConfigItem $CFG_FILE_PATH $CFG_FILE_TYPE $CFG_FILE_ACCESS $1 $2 $3
}


