#!/bin/sh
sleep 10
num=1
tysniffer -f /mnt/tysniffer.json -b true 
while true
do
#注意!!!有些时候编译出来的固件不需要加-ef 有些要
	ps -ef | grep "tysniffer -f" | grep -v grep
	if [ $? -eq 0 ]; then
		echo "tysniffer process start"
	else
        tysniffer -k all 
        sleep 5
		tysniffer -f /mnt/tysniffer.json -b true 
		#echo "cgps start failed"
	fi
    let num+=1
	sleep 30

     if [ $num -gt 240 ]; then
        tysniffer -k all 
        sleep 5
	    tysniffer -f /mnt/tysniffer.json -b true 
        num=0
     fi
done
