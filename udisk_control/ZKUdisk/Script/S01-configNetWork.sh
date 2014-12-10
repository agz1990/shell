#!/bin/sh

echo 'I am Runing....'
[ "$USER" = "root" ] && ifconfig eth0 192.168.0.234
i=1
while [ "$i" != 20 ]; do

	echo "ifconfig eth0:$i 192.168.$i.234"
	[ "$USER" = "root" ] && ifconfig eth0:$i 192.168.$i.234
	i=`expr $i + 1`

done

[ "$USER" = "root" ] &&  echo  "exit 0"  && exit

return 0
