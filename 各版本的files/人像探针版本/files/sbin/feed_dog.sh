#!/bin/sh
while [ 1 ]
do
    echo 255 >/sys/class/gpio/gpio2/value
#    echo 255 >/sys/class/leds/tp-link\:green\:dog/brightness
    sleep 1
#    echo 0 >/sys/class/leds/tp-link\:green\:dog/brightness
    echo 0 >/sys/class/gpio/gpio2/value
    sleep 1
done
