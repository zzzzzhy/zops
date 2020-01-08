#!/bin/sh
sleep 10
while true
do
        echo -e "AT+QGPS=1\r\n" > /dev/ttyUSB2 
        if [ $? -eq 0 ];then
#                 echo 'gps start success'
                return
        else
                echo 'gps restart'
                sleep 5
        fi
done
