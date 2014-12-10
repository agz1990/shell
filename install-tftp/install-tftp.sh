#!/bin/sh
apt-get install tftp-hpa tftpd-hpa xinetd
chmod -R 777 /tftpboot
cp tftp  /etc/xinetd.d/
cp inetd.conf /etc/
cp tftpd-hpa /etc/default/
