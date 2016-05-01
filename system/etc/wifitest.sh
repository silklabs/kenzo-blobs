#!/system/bin/sh
rmmod wlan
sleep 2
insmod /system/lib/modules/wlan.ko con_mode=5
sleep 3
setprop persist.sys.openwifi_L 0
exit 0

