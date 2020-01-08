#!/bin/sh

num=0
sleep 5
wpa_supplicant -Dwired -ieth1 -c/etc/config/wpa-supplicant.conf -B 
sleep 10
while true
do
    ping -s1 -c1 114.114.114.114 >/dev/null
    if [ "$?" -eq "0" ]; then
        num=0
        sleep 5
    else 
        tmp=$((num%12))
        if [ $tmp == 0 ]; then
            wpa_cli reassociate
        fi
        let num+=1
        sleep 5
    fi
    #wpa_cli status | awk '{print $3}'
    if [ $num -gt 36 ]; then
        wpa_cli disconnect
        sleep 1
        killall wpa_supplicant
        sleep 1
        wpa_supplicant -Dwired -ieth1 -c/etc/config/wpa-supplicant.conf -B 
        sleep 5
        num=0
    fi
done