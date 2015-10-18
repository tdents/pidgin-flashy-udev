#!/bin/bash
dVendor=$(cat /etc/pidgin-flashy.conf | grep -v -e '^#' | grep 'Vendor' | cut -d '=' -f2 )
dProduct=$(cat /etc/pidgin-flashy.conf | grep -v -e '^#' | grep 'Product' | cut -d '=' -f2 )
#devpath=$(ls /sys/bus/usb/devices/*/idVendor | xargs grep -rl $dVendor | awk -F '/idVendor' '{ print $1 "/idProduct" }' | xargs grep -rl $dProduct | awk -F '/idProduct' '{ print $1 }' )
devpath=$(udevadm trigger -v -a idVendor=$dVendor -a idProduct=$dProduct);
if [ -n "$devpath" ]; then 
chgrp led $devpath/power/level
chgrp led $devpath/power/autosuspend_delay_ms
chgrp led $devpath/power/control
chgrp led $devpath/power/autosuspend
chmod "664" $devpath/power/level
chmod "664" $devpath/power/control
chmod "664" $devpath/power/autosuspend_delay_ms
chmod "664" $devpath/power/autosuspend
echo 0 > $devpath/power/autosuspend_delay_ms
echo auto > $devpath/power/level
fi
