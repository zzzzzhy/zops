#!/bin/sh
killall feed_dog.sh 2> /dev/null
sleep 1
echo 0 > /sys/class/gpio/gpio2/value
