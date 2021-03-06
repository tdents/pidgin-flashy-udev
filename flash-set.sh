#!/bin/bash
source /etc/pidgin-flashy.conf
devpath=$(udevadm trigger -v -a idVendor=${idVendor} -a idProduct=${idProduct});

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
fi
