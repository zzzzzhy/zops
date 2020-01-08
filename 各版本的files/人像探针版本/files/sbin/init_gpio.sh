#!/bin/sh
echo 2 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio2/direction

