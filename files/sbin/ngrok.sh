#!/bin/sh
sleep 10
while [ -z "$(ifconfig | grep wwan0)" ]; do
        sleep 2
done
mac=ifconfig eth0 | awk '/HWaddr/{print $5}' | awk -F: '{print $1 $2 $3 $4 $5 $6}'
ngrokc -SER[Shost:ngrokc.wifi.tywork.top,Sport:2334] -AddTun[Type:http,Lhost:127.0.0.1,Lport:2333,Sdname:"$mac"] -AddTun[Type:tcp,Lhost:127.0.0.1,Lport:22,Rport:2335] 
while true
do
    ps -ef | grep "ngrokc" | grep -v grep
	if [ $? -eq 0 ]; then
        sleep 30
    else
        ngrokc -SER[Shost:ngrokc.wifi.tywork.top,Sport:2334] -AddTun[Type:http,Lhost:127.0.0.1,Lport:2333,Sdname:$mac] -AddTun[Type:tcp,Lhost:127.0.0.1,Lport:22,Rport:2335] 
        sleep 30
    fi
done