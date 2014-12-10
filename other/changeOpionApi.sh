#!/bin/sh

oringeFile=$1
tmpFile="${oringeFile}.tmp"

cp $oringeFile $tmpFile

sed  $tmpFile \
-e 's|GetOptionIntValue(\([^,]*\)[^)]*|GetIntOption(\1|g' \
-e 's|SetOptionIntValue|SetIntOption|g' \
-e 's|SetOptionStrValue|SetStrOption|g' \
-e 's|GetOptionStrValue(\([^,]*,\)[^,]*,|GetStrOption(\1|g' > $oringeFile

