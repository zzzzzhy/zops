#!/bin/sh
sleep 10

while true
do
#注意!!!有些时候编译出来的固件不需要加-ef 有些要
	ps -ef | grep "cgps -a" | grep -v grep
	if [ $? -eq 0 ]; then
 
		echo "cgps process start"
	else

		screen -dm cgps -a 192.168.1.255 -p9090 -t3 >/dev/null 2>&1 
		echo "cgps start failed"
	fi
	sleep 5
done
