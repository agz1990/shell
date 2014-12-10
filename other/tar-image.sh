#!/bin/sh
if [ -z $1 ];then
        echo "ERROR! Please Input a tar packet Name! "
                exit 1
fi

find | egrep "(.*\.jpg|.*\.png|.*\.gif)"  | sed -n 's|\.\/||'p | xargs tar -zcvf $1
