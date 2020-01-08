#!/bin/sh
sleep 60
while true
do
        ping -c 3 www.baidu.com > /dev/null 2>&1
        if [ $? -eq 0 ];then
#                 echo 'Connected'
                sleep 15
                continue
        else
                echo 'No network,reconnect 4G'
                ifdown LTE
                sleep 5
                ifup LTE
                sleep 20
        fi
done

